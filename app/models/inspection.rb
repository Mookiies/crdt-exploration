# frozen_string_literal: true
require 'af_crdt'

class Inspection < ApplicationRecord
  include AfHideableModel::Hideable

  has_many :areas, autosave: true, dependent: :destroy

  default_scope { without_hidden }
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  TIMESTAMPED_FIELDS = %i[name note].freeze
  include TimestampDsl

  def self.update_or_create_by(args, attributes, &block)
    transaction(isolation: :serializable) do
      record = lock.find_with_hidden.find_by(args)
      accepted_attributes = attribute_names.map(&:to_sym)
      puts accepted_attributes.inspect
      trimmed_attributes = attributes.slice(*accepted_attributes)
      if record.nil?
        record = new(trimmed_attributes)
        block.call(record)
      else
        puts 'trimmed_attributes.inspect'
        puts trimmed_attributes.inspect
        record.assign_attributes(trimmed_attributes)
        block.call(record)
      end
    end
  end
end