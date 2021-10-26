# frozen_string_literal: true

class Inspection < ApplicationRecord
  has_many :areas
  accepts_nested_attributes_for :areas

  # This is useful for supporting creation w/o id's
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  def self.update_or_create_by(args, attributes)
    record = find_by(args)
    if record.nil?
      record = create(attributes)
    else
      record.assign_attributes(attributes)
    end
    record
  end
end
