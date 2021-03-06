# frozen_string_literal: true

module Types
  class AreasTimestampAttributes < Types::BaseInputObject
    argument :name, String, required: false
    argument :position, String, required: false
  end
end
