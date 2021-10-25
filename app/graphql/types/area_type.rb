module Types
  class AreaType < Types::BaseObject
    field :id, ID, null: false
    field :uuid, String, null: false
    field :name, String, null: false
    field :position, Integer, null: true
    field :tombstone, Boolean, null: false
    field :inspection_id, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :items, [Types::ItemType], null: false
  end
end
