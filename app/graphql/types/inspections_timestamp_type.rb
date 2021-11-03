module Types
  class InspectionsTimestampType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :note, String, null: true
    field :inspection_id, Integer, null: false
  end
end
