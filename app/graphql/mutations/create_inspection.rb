module Mutations
  class CreateInspection < BaseMutation
    # Return fields
    field :errors, [String], null: false
    field :success, Boolean, null: false
    field :inspection, Types::InspectionType, null: false

    argument :inspection, Types::InspectionAttributes, required: true

    def resolve(inspection:)
      inspection_hash = inspection.to_hash
      areas = inspection_hash[:areas]
      record = Inspection.create(inspection_hash.except(:areas))
      areas&.each do |area|
        area_args = area.to_hash.merge(inspection: record)
        items = area_args.delete(:items)
        area_record = Area.create(area_args)
        items&.each do |item|
          Item.create(item.to_hash.merge(area: area_record))
        end
      end

      if record.save
        { success: true, inspection: record, errors: []}
      else
        { success: false, inspection: nil, errors: ['error']}
      end
    end
  end
end
