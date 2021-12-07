# frozen_string_literal: true

module Mutations
  class CreateOrUpdateInspection < BaseMutation
    # Return fields
    field :errors, [String], null: false
    field :success, Boolean, null: false
    field :inspection, Types::InspectionType, null: true

    argument :inspection, Types::InspectionAttributes, required: true

    def resolve(inspection:)
      to_append_attributes = %i[timestamps areas items]

      # TODO: how to wrap all of this into one transaction (including timestamps)
      inspection_hash = inspection.to_hash
      inspection_hash = inspection_hash.deep_transform_keys do |key|
        if to_append_attributes.include?(key)
          "#{key}_attributes".to_sym
        else
          key
        end
      end
      areas = inspection_hash[:areas_attributes]
      puts inspection_hash.inspect
      Inspection.includes(areas: :items)
                .update_or_create_by({ uuid: inspection_hash[:uuid] }, inspection_hash) do |record|
        #TODO how to handle soft deleted records?
        # we want to apply these changes but don't want them in the final result...
        # This if is just an escape for now to bail out of doing anything to deleted inspections
        if deleted?(inspection_hash) || record.hidden?
          record.hide
          if record.save
            return { success: true, inspection: nil, errors: [] }
          else
            return { success: false, inspection: nil, errors: ['error'] }
          end
        end

        areas&.each do |area|
          area_record = record.areas.find { |a| a.uuid == area[:uuid] }
          area_args = area.to_hash.except(:items_attributes, :_deleted)
          if area_record.present?
            area_record.assign_attributes(area_args)
          else
            # TODO hacky workaround to default scope visible
            if Area.unscoped.find_by(uuid: area_args[:uuid])
              # This case means that the record was not loaded originially (and if found here is therefore deleted)
              # Do nothing for now (but this is bad CRDT)
            else
              area_record = record.areas.new(area_args)
            end
          end

          if deleted?(area) && area_record.present?
            area_record.hide
          end

          items = area.to_hash[:items_attributes]
          items&.each do |item|
            item_record = area_record.items.find { |i| i.uuid == item[:uuid] }
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
          { success: true, inspection: record, errors: ['testing'] }
        else
          { success: false, inspection: nil, errors: ['error'] }
        end
      end
    end

    private

    def deleted?(obj)
      !!obj[:_deleted]
    end
  end
end
