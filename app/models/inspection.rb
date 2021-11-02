# frozen_string_literal: true

# TODO tomorrow
# replace datetime with HLC's
# Write some tests to validate inspection. Make iterating easier.
# how global is HLC? Per field (is the answer the same server vs client)
# urql stuff

class Inspection < ApplicationRecord
  has_many :areas, autosave: true, dependent: :destroy

  has_one :timestamps, autosave: true, class_name: 'InspectionsTimestamp'
  default_scope { eager_load(:timestamps) }

  after_initialize :init_timestamps, if: -> { timestamps.nil? }
  before_save :check_timestamps, if: :has_changes_to_save?

  # This is useful for supporting creation w/o id's
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  TIMESTAMPED_FIELDS = [:name].freeze

  def timestamps_attributes=(attributes)
    attributes = attributes.with_indifferent_access
    existing_record = timestamps

    if existing_record
      existing_record.assign_attributes(attributes.slice(*TIMESTAMPED_FIELDS))
    else
      build_timestamps(attributes)
    end
  end

  def self.update_or_create_by(args, attributes)
    record = find_by(args)
    accepted_attributes = attribute_names.map(&:to_sym).push(:timestamps_attributes)
    trimmed_attributes = attributes.slice(*accepted_attributes)
    if record.nil?
      record = new(trimmed_attributes)
    else
      record.assign_attributes(trimmed_attributes)
    end
    record
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
      next unless (TIMESTAMPED_FIELDS.map(&:to_s)).include?(field_name)

      next_ts = timestamps[field_name] || DateTime.now.to_s
      current_ts = timestamps.send("#{field_name}_was") || 100.years.ago.to_s

      next_value = self[field_name]
      current_value = send("#{field_name}_was")

      next_lww = CrdtDsl::Strategies::Lww.new(value: next_value, timestamp: next_ts)
      current_lww = CrdtDsl::Strategies::Lww.new(value: current_value, timestamp: current_ts)

      result = current_lww.merge(next_lww)

      # Change timestamp is older. Rollback change to field and to it's timestamp
      timestamps[field_name] = result.timestamp
      self[field_name] = result.value
    end
  end
end

# Test cases
# - Various method or creating and updating
# - Respects strategy for timestamps
# - Cannot update just the timestamp in isolation
# - Can assign with or without timestamp and correct behavior is there
