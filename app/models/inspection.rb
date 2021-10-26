# frozen_string_literal: true

class Inspection < ApplicationRecord
  has_many :areas, autosave: true

  has_one :inspections_timestamp, autosave: true
  # accepts_nested_attributes_for :areas

  before_save :check_timestamps, if: :has_changes_to_save?
  after_create :init_timestamps

  # This is useful for supporting creation w/o id's
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  # TODO: is there a better way to represent this w/ symbols or something?
  TIMESTAMPED_FIELDS = ['name'].freeze

  def self.update_or_create_by(args, attributes)
    record = find_by(args)
    if record.nil?
      record = create(attributes)
    else
      record.assign_attributes(attributes)
    end
    record
  end

  def check_timestamps
    return unless inspections_timestamp

    changes.each do |change|
      field_name = change[0]
      next unless TIMESTAMPED_FIELDS.include?(field_name)

      field_ts = inspections_timestamp["#{field_name}_ts"]
      if false       # TODO: do comparison here
        previous_value = change[1][0]
        self[field_name] = previous_value
      else
        inspections_timestamp["#{field_name}_ts"] = DateTime.now.to_s
      end
    end
  end

  def init_timestamps
    InspectionsTimestamp.create(inspection_id: id, name_ts: DateTime.now.to_s)
  end
end
