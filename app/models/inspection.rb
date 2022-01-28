# frozen_string_literal: true

class Inspection < ApplicationRecord
  include AfHideableModel::Hideable

  ####### Timestamp related
  TIMESTAMP_CLASS_NAME = 'InspectionsTimestamp'
  TIMESTAMPED_FIELDS = %i[name note].freeze
  include TimestampDsl
  #######

  has_many :areas, autosave: true, dependent: :destroy

  # This is useful for supporting creation w/o id's
  attribute :uuid, :string, default: -> { SecureRandom.uuid }
end

# Test cases
# - Various method or creating and updating
# - Respects strategy for timestamps
# - Cannot update just the timestamp in isolation
# - Can assign with or without timestamp and correct behavior is there
