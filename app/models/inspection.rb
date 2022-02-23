# frozen_string_literal: true

class Inspection < ApplicationRecord
  include AfHideableModel::Hideable
  serialize :timestamps

  after_initialize :init_timestamps
  has_many :areas, autosave: true, dependent: :destroy

  default_scope { without_hidden }

  before_save :discard_erroneous_timestamps, if: -> { will_save_change_to_timestamps? }
  before_save :check_timestamps, if: :has_changes_to_save?

  # This is useful for supporting creation w/o id's
  attribute :uuid, :string, default: -> { SecureRandom.uuid }
  attribute :timestamps, :json

  TIMESTAMPED_FIELDS = %i[name note].freeze

  def init_timestamps
    self.timestamps ||= TIMESTAMPED_FIELDS.to_h { |x| [x, nil] }
  end

  # def timestamps_attributes=(attributes)
  #   attributes = attributes.with_indifferent_access
  #   existing_record = timestamps
  #
  #   if existing_record
  #     existing_record.assign_attributes(attributes.slice(*TIMESTAMPED_FIELDS))
  #   else
  #     build_timestamps(attributes)
  #   end
  # end
  #
  def self.update_or_create_by(args, attributes, &block)
    transaction(isolation: :serializable) do
      record = lock.find_with_hidden.find_by(args)
      accepted_attributes = attribute_names.map(&:to_sym)
      trimmed_attributes = attributes.slice(*accepted_attributes)
      if record.nil?
        record = new(trimmed_attributes)
        block.call(record)
      else
        record.assign_attributes(trimmed_attributes)
        block.call(record)
      end
    end
  end
  #
  # # nil - because sent from online
  # # nil - because it already existed
  # # timestamps - because made in app
  # # [db state, next]
  # # [[nil, x], [y]] ==> infinitely old
  # # [[x], [nil, y]] ==> infinetly new
  # #
  # # [[nil, x], [nil, y]] => [server_ts, y]
  # # [[nil, x], [ts, y]] => [ts, y]
  # # [[ts_x, x], [nil, y]] => [server_ts, y]
  # # [[ts_x, x], [ts_y, y]] => x >= y ? [ts_x, x] : [ts_y, y]
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

      self.timestamps[field_name] = result.timestamp.pack
      self[field_name] = result.value
    end
  end

  private

  def timestamped_field?(field_name)
    (TIMESTAMPED_FIELDS.map(&:to_s)).include?(field_name)
  end

  def discard_erroneous_timestamps
    timestamps.each do | field_name, timestamp|
      puts "#{field_name} : #{timestamp}"
      if timestamp_changed(field_name) && !will_save_change_to_attribute?(field_name)
        self.timestamps[field_name] = get_database_ts(field_name)
      end
    end
  end

  def get_database_ts(field_name)
    database_ts = timestamps_was
    database_ts && database_ts[field_name]
  end

  def timestamp_changed(field_name)
    database_ts = get_database_ts(field_name)
    current_ts = timestamps[field_name]
    database_ts != current_ts
  end

  def compute_current_ts(field_name)
    database_ts = get_database_ts(field_name)
    database_ts.present? ? HybridLogicalClock::Hlc.unpack(database_ts) : HybridLogicalClock::Hlc.new(node: '???', now: 0)
  end

  def compute_next_ts(field_name)
    if timestamp_changed(field_name)
      # Change came with a timestamp, use timestamp that came with change
      HybridLogicalClock::Hlc.unpack(timestamps[field_name])
    elsif timestamps[field_name].present?
      # Change came without a timestamp, generate a winning HLC
      HybridLogicalClock::Hlc.unpack(timestamps[field_name]).increment
    else
      # No existing HLC
      HybridLogicalClock::Hlc.new(node: '???', now: Time.current.to_i)
    end
  end
end