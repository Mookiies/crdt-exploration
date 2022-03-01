module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :all_inspections, [Types::InspectionType], null: false
    def all_inspections
      Inspection.all
      # Inspection.includes(:areas => [:items]).all
      Inspection.eager_load(:timestamps, :areas => [:timestamps, :items]).all
    end

    field :inspection, Types::InspectionType, null: true do
      argument :uuid, String, required: true
    end
    def inspection(uuid)
      Inspection.find_by(uuid)
    end
  end
end
