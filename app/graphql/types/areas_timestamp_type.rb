module Types
  class AreasTimestampType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :position, String, null: true
    field :area_id, Integer, null: false
  end
end
