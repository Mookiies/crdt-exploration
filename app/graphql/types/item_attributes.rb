# frozen_string_literal: true

module Types
  class ItemAttributes < Types::BaseInputObject
    description 'Attributes for creating an item'
    # TODO: can this be re-used for updates and if so how to mark everything optional
    argument :id, Integer, required: false
    argument :name, String, required: true
    argument :note, String, required: false
    argument :flagged, Boolean, required: false
    argument :position, Integer, required: false
    argument :tombstone, Boolean, required: false

  end
end
