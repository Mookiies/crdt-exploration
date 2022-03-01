# frozen_string_literal: true

module Types
  class InspectionAttributes < Types::BaseInputObject
    description 'Attributes for creating an inspection'
    argument :id, Integer, required: false
    argument :uuid, String, required: true
    argument :name, String, required: false
    argument :note, String, required: false
    argument :tombstone, Boolean, required: false

    argument :areas, [Types::AreaAttributes], required: false
    argument :timestamps, Types::InspectionsTimestampAttributes, required: false

    argument  :_deleted, Boolean, required: false
  end
end
