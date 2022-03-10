# frozen_string_literal: true

module Types
  class AreaAttributes < Types::BaseInputObject
    description 'Attributes for creating an area'
    # TODO: can this be re-used for updates and if so how to mark everything optional
    argument :id, Integer, required: false
    argument :uuid, String, required: true
    argument :name, String, required: false
    argument :position, Integer, required: false
    argument :tombstone, Boolean, required: false

    argument :items, [Types::ItemAttributes], required: false
    argument :timestamps, Types::AreasTimestampAttributes, required: false

    argument  :_deleted, Boolean, required: false

  end
end
