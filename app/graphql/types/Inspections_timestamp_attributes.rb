# frozen_string_literal: true

module Types
  class InspectionsTimestampAttributes < Types::BaseInputObject
    argument :name, String, required: false
  end
end
