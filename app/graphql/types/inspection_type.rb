module Types
  class InspectionType < Types::BaseObject
    field :id, ID, null: false
    field :uuid, String, null: false
    field :name, String, null: false
    field :note, String, null: true
    field :tombstone, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :timestamps, GraphQL::Types::JSON, null: true

    field :areas, [Types::AreaType], null: false
  end
end
