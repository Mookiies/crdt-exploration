# frozen_string_literal: true

module Types
  class InspectionAttributes < Types::BaseInputObject
    description 'Attributes for creating an inspection'
    # TODO: can this be re-used for updates and if so how to mark everything optional
    argument :id, Integer, required: false
    argument :name, String, required: true
    argument :tombstone, Boolean, required: false
    argument :areas, [Types::AreaAttributes], required: false
  end
end
