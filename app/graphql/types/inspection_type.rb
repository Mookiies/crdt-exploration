module Types
  class InspectionType < Types::BaseObject
    field :id, ID, null: false
    field :uuid, String, null: false
    field :name, String, null: false
    field :tombstone, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :timestamps, Types::InspectionsTimestampType, null: false

    field :areas, [Types::AreaType], null: false
  end
end
