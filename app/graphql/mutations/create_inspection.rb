module Mutations
  class CreateInspection < BaseMutation
    # Return fields
    field :errors, [String], null: false
    field :success, Boolean, null: false
    field :inspection, Types::InspectionType, null: false

    argument :inspection, Types::InspectionAttributes, required: true

    def resolve(inspection:)
      inspection_hash = inspection.to_hash
      record = Inspection.create(inspection_hash)

      if record.save
        { success: true, inspection: record, errors: []}
      else
        { success: false, inspection: nil, errors: ['error']}
      end
    end
  end
end
