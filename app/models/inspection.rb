# frozen_string_literal: true

class Inspection < ApplicationRecord
  has_many :areas, autosave: true, dependent: :destroy

  has_one :timestamps, autosave: true, class_name: 'InspectionsTimestamp'
  default_scope { eager_load(:timestamps) }
  # TODO: are there migration issues with this association (ie. starting from scratch this fails)?

  before_save :check_timestamps, if: :has_changes_to_save?

  # This is useful for supporting creation w/o id's
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  TIMESTAMPED_FIELDS = [:name].freeze # TODO convert to set with indifferent access

  def timestamps_attributes=(attributes)
    attributes = attributes.with_indifferent_access
    # TODO: support association name besides timestamps?
    existing_record = timestamps

    if existing_record
      existing_record.assign_attributes(attributes.slice(*TIMESTAMPED_FIELDS))
    else
      # TODO: support association name besides timestamps?
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

  # TODO: Prevent changes to timestamps unless there are also changes to the name field
  def check_timestamps
    if timestamps.nil?
      # TODO is there a better way to handle default intialization?
      # Timestamps do not exist for this record yet.
      ts = TIMESTAMPED_FIELDS.to_h { |x| [x, DateTime.now.to_s]}
      build_timestamps(ts)
      return
    end

    changes.each do |change|
      field_name = change[0]
      next unless (TIMESTAMPED_FIELDS.map(&:to_s)).include?(field_name)

      # Change has come without a timestamp. Default to use server time for this change
      timestamps[field_name] = DateTime.now.to_s && next unless timestamps.send("#{field_name}_changed?")

      change_ts = timestamps[field_name]
      prev_ts = timestamps.send("#{field_name}_was")

      next if newer_timestamp?(change_ts, prev_ts)

      # Change timestamp is older. Rollback change to field and to it's timestamp
      timestamps[field_name] = prev_ts
      self[field_name] = send("#{field_name}_was")
    end

  #  TODO go over changes to timestamps and make sure there are none that don't correspond to actual change
  end

  def newer_timestamp?(change_ts, prev_ts)
    return true if prev_ts.nil?

    parsed_change = DateTime.parse(change_ts)
    parsed_prev = DateTime.parse(prev_ts)
    parsed_change - parsed_prev >= 0
  end
end

# Test cases
# - Various method or creating and updating
# - Respects strategy for timestamps
# - Cannot update just the timestamp in isolation
# - Can assign with or without timestamp and correct behavior is there
