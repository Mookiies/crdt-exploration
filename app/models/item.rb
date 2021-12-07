class Item < ApplicationRecord
  include AfHideableModel::Hideable

  belongs_to :area, optional: false

  # This is useful for supporting creation w/o id's
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  default_scope { without_hidden }

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
