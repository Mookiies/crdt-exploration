module Mutations
  class CreateOrUpdateInspection < BaseMutation
    # Return fields
    field :errors, [String], null: false
    field :success, Boolean, null: false
    field :inspection, Types::InspectionType, null: false

    argument :inspection, Types::InspectionAttributes, required: true

    def resolve(inspection:)
      inspection_hash = inspection.to_hash
      areas = inspection_hash[:areas_attributes]
      record = Inspection.update_or_create_by({ uuid: inspection_hash[:uuid] }, inspection_hash.except(:areas_attributes))

      areas&.each do |area|
        area_args = area.to_hash.merge(inspection: record)
        items = area_args.delete(:items_attributes)
        area_record = Area.update_or_create_by({ uuid: area_args[:uuid] }, area_args)
        items&.each do |item|
          Item.update_or_create_by({ uuid: item[:uuid] }, item.to_hash.merge(area: area_record))
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
