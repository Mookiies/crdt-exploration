module Mutations
  class CreateOrUpdateInspection < BaseMutation
    # Return fields
    field :errors, [String], null: false
    field :success, Boolean, null: false
    field :inspection, Types::InspectionType, null: false

    argument :inspection, Types::InspectionAttributes, required: true

    def resolve(inspection:)
      # TODO: how to wrap all of this into one transaction (including timestamps)
      inspection_hash = inspection.to_hash
      areas = inspection_hash[:areas_attributes]
      record = Inspection.includes(areas: :items).update_or_create_by({ uuid: inspection_hash[:uuid] }, inspection_hash)

      # TODO how and when to delete areas based on the array
      # TODO have to explicitly specify that something is deleted (deleted_at column or something)
      areas&.each do |area|
        area_record = record.areas.find{ |a| a.uuid == area[:uuid] }
        if deleted?(area)
          record.areas.destroy(area_record) if area_record.present?
          next
        end

        area_args = area.to_hash.except(:items_attributes, :_deleted)
        if area_record.nil?
          area_record = record.areas.new(area_args)
        else
          area_record.assign_attributes(area_args)
        end

        items = area.to_hash[:items_attributes]
        items&.each do |item|
          item_record = area_record.items.find{ |i| i.uuid == item[:uuid] }
          if deleted?(item)
            area_record.items.destroy(item_record) if item_record.present?
            next
          end

          item_args = item.to_hash.except(:_deleted)
          if item_record.nil?
            area_record.items.new(item_args)
          else
            item_record.assign_attributes(item_args)
          end
        end
      end

      if record.save
        { success: true, inspection: record, errors: [] }
      else
        { success: false, inspection: nil, errors: ['error'] }
      end
    end

    private

    def deleted?(obj)
      !!obj[:_deleted]
    end
  end
end
