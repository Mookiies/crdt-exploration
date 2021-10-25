module Types
  class MutationType < Types::BaseObject
    field :create_inspection, mutation: Mutations::CreateInspection
    field :create_or_update_inspection, mutation: Mutations::CreateOrUpdateInspection
  end
end
