class Area < ApplicationRecord
  belongs_to :inspection, optional: false
  has_many :items
  accepts_nested_attributes_for :items

  # This is useful for supporting creation w/o id's
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  def self.update_or_create_by(args, attributes)
    record = find_by(args)
    if record.nil?
      record = create(attributes)
    else
      record.update(attributes)
    end
    record
  end
end
