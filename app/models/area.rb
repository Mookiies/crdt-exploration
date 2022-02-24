# frozen_string_literal: true
require 'af_crdt'

class Area < ApplicationRecord
  include AfHideableModel::Hideable

  belongs_to :inspection, optional: false
  has_many :items, autosave: true, dependent: :destroy

  default_scope { without_hidden }

  # This is useful for supporting creation w/o id's
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  TIMESTAMPED_FIELDS = %i[name position].freeze
  include TimestampDsl

  def self.update_or_create_by(args, attributes, &block)
    transaction(isolation: :serializable) do
      record = lock.find_with_hidden.find_by(args)
      accepted_attributes = attribute_names.map(&:to_sym)
      trimmed_attributes = attributes.slice(*accepted_attributes)
      if record.nil?
        record = new(trimmed_attributes)
        block.call(record)
      else
        record.assign_attributes(trimmed_attributes)
        block.call(record)
      end
    end
  end
end
