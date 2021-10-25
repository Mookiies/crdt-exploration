class Item < ApplicationRecord
  belongs_to :area, optional: false

  # This is useful for supporting creation w/o id's
  attribute :uuid, :string, default: -> { SecureRandom.uuid }
end
