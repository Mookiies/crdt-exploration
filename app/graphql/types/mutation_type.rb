module Types
  class MutationType < Types::BaseObject
    field :create_inspection, mutation: Mutations::CreateInspection
  end
end
