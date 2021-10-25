# frozen_string_literal: true

class Inspection < ApplicationRecord
  has_many :areas
  accepts_nested_attributes_for :areas

  # This is useful for supporting creation w/o id's
  attribute :uuid, :string, default: -> { SecureRandom.uuid }
end
