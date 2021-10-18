# frozen_string_literal: true

module Types
  class AreaAttributes < Types::BaseInputObject
    description 'Attributes for creating an area'
    # TODO: can this be re-used for updates and if so how to mark everything optional
    argument :id, Integer, required: false
    argument :name, String, required: true
    argument :position, Integer, required: false
    argument :tombstone, Boolean, required: false

    #  TODO item type
  end
end
