# frozen_string_literal: true

class Inspection < ApplicationRecord
  has_many :areas, autosave: true, dependent: :destroy

  has_one :timestamps, autosave: true, class_name: 'InspectionsTimestamp', dependent: :destroy
  default_scope { eager_load(:timestamps) }

  after_initialize :init_timestamps, if: -> { timestamps.nil? }

  before_save :discard_erroneous_timestamps, if: -> { timestamps.has_changes_to_save? }
  before_save :check_timestamps, if: :has_changes_to_save?

  # This is useful for supporting creation w/o id's
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  TIMESTAMPED_FIELDS = %i[name note].freeze

  def timestamps_attributes=(attributes)
    attributes = attributes.with_indifferent_access
    existing_record = timestamps

    if existing_record
      existing_record.assign_attributes(attributes.slice(*TIMESTAMPED_FIELDS))
    else
      build_timestamps(attributes)
    end
  end

  def self.update_or_create_by(args, attributes, &block)
    record = find_by(args)
    accepted_attributes = attribute_names.map(&:to_sym).push(:timestamps_attributes)
    trimmed_attributes = attributes.slice(*accepted_attributes)
    if record.nil?
      record = new(trimmed_attributes)
      record.with_lock do
        block.call(record)
      end
    else
      record.with_lock do # TODO make this work with lock version instead
        record.assign_attributes(trimmed_attributes)
        block.call(record)
      end
    end
  end

  def init_timestamps
    build_timestamps
  end

  # nil - because sent from online
  # nil - because it already existed
  # timestamps - because made in app
  # [db state, next]
  # [[nil, x], [y]] ==> infinitely old
  # [[x], [nil, y]] ==> infinetly new
  #
  # [[nil, x], [nil, y]] => [server_ts, y]
  # [[nil, x], [ts, y]] => [ts, y]
  # [[ts_x, x], [nil, y]] => [server_ts, y]
  # [[ts_x, x], [ts_y, y]] => x >= y ? [ts_x, x] : [ts_y, y]
  def check_timestamps
    changes.each do |change|
      field_name = change[0]
      next unless timestamped_field?(field_name)

      next_ts = compute_next_ts(field_name)
      current_ts = compute_current_ts(field_name)

      next_value = self[field_name]
      current_value = send("#{field_name}_was")

      next_lww = CrdtDsl::Strategies::Lww.new(value: next_value, timestamp: next_ts)
      current_lww = CrdtDsl::Strategies::Lww.new(value: current_value, timestamp: current_ts)

      result = current_lww.merge(next_lww)

      timestamps[field_name] = result.timestamp.pack
      self[field_name] = result.value
    end
  end

  private

  def timestamped_field?(field_name)
    (TIMESTAMPED_FIELDS.map(&:to_s)).include?(field_name)
  end

  def discard_erroneous_timestamps
    timestamps.changes.each do |change|
      field_name = change[0]
      unless timestamped_field?(field_name) && send("#{field_name}_changed?")
        timestamps[field_name] = timestamps.send("#{field_name}_was")
      end
    end
  end

  def compute_current_ts(field_name)
    if timestamps.send("#{field_name}_changed?") && timestamps.send("#{field_name}_was").present?
      # There existed a non-null HLC for this record already
      HybridLogicalClock::Hlc.unpack(timestamps.send("#{field_name}_was"))
    else
      # No previous HLC, generate an old one that will lose comparison
      HybridLogicalClock::Hlc.new(node: '???', now: 0)
    end
  end

  def compute_next_ts(field_name)
    if timestamps.send("#{field_name}_changed?")
      # Change came with a timestamp, use timestamp that came with change
      HybridLogicalClock::Hlc.unpack(timestamps[field_name])
    elsif timestamps[field_name].present?
      # Change came without a timestamp, generate a winning HLC
      HybridLogicalClock::Hlc.unpack(timestamps[field_name]).send
    else
      # No existing HLC
      HybridLogicalClock::Hlc.new(node: '???', now: Time.current.to_i)
    end
  end
end

# Test cases
# - Various method or creating and updating
# - Respects strategy for timestamps
# - Cannot update just the timestamp in isolation
# - Can assign with or without timestamp and correct behavior is there
