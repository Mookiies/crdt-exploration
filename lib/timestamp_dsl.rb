# frozen_string_literal: true

require "active_support/concern"
require "active_record/associations"
require "active_record/callbacks"

# DSL for timestamp
# Requires TIMESTAMP_CLASS_NAME and TIMESTAMPED_FIELDS constants to be defined in the parent class
module TimestampDsl
  extend ActiveSupport::Concern

  included do |base|
    cattr_accessor :timestamped_fields, default: base::TIMESTAMPED_FIELDS

    has_one :timestamps, autosave: true, class_name: base::TIMESTAMP_CLASS_NAME, dependent: :destroy
    default_scope { eager_load(:timestamps) }

    after_initialize :init_timestamps, if: -> { timestamps.nil? }

    before_save :discard_erroneous_timestamps, if: -> { timestamps.has_changes_to_save? }
    before_save :check_timestamps, if: :has_changes_to_save?
  end

  def update_or_create_by(args, attributes, &block)
    transaction(isolation: :serializable) do
      record = lock.find_with_hidden.find_by(args)
      accepted_attributes = attribute_names.map(&:to_sym).push(:timestamps_attributes)
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

  def assign_attributes_with_timestamps(attributes)
    return if attributes.blank?

    attributes = attributes.stringify_keys
    timestamps_attributes = attributes['timestamps_attributes']
    raise ArgumentError if timestamps.nil?

    assign_attributes(attributes)
    timestamps.assign_attributes(timestamps_attributes)
  end

  def timestamps_attributes=(attributes)
    attributes = attributes.with_indifferent_access
    existing_record = timestamps

    if existing_record
      existing_record.assign_attributes(attributes.slice(timestamped_fields))
    else
      build_timestamps(attributes)
    end
  end

  def init_timestamps
    build_timestamps
  end

  def check_timestamps
    changes_to_save.each do |change|
      field_name = change[0]
      next unless timestamped_field?(field_name)

      next_ts = compute_next_ts(field_name)
      current_ts = compute_current_ts(field_name)
      next_value = send("#{field_name}_change_to_be_saved")[1]
      current_value = send("#{field_name}_in_database")

      next_lww = CrdtDsl::Strategies::Lww.new(value: next_value, timestamp: next_ts)
      current_lww = CrdtDsl::Strategies::Lww.new(value: current_value, timestamp: current_ts)

      result = current_lww.merge(next_lww)
      timestamps[field_name] = result.timestamp.pack
      self[field_name] = result.value
    end
  end

  def discard_erroneous_timestamps
    timestamps.changes.each do |change|
      field_name = change[0]
      unless timestamped_field?(field_name) && send("will_save_change_to_#{field_name}?")
        timestamps[field_name] = timestamps.send("#{field_name}_in_database")
      end
    end
  end

  def timestamped_field?(field_name)
    timestamped_fields.map(&:to_s).include?(field_name)
  end

  def compute_current_ts(field_name)
    if timestamps.send("will_save_change_to_#{field_name}?") && timestamps.send("#{field_name}_in_database").present?
      # There existed a non-null HLC for this record already
      HybridLogicalClock::Hlc.unpack(timestamps.send("#{field_name}_in_database"))
    else
      # No previous HLC, generate an old one that will lose comparison
      HybridLogicalClock::Hlc.new(node: '???', now: 0)
    end
  end

  def compute_next_ts(field_name)
    if timestamps.send("will_save_change_to_#{field_name}?")
      # Change came with a timestamp, use timestamp that came with change
      HybridLogicalClock::Hlc.unpack(timestamps[field_name])
    elsif timestamps[field_name].present?
      # Change came without a timestamp, generate a winning HLC
      HybridLogicalClock::Hlc.unpack(timestamps[field_name]).increment
    else
      # No existing HLC
      HybridLogicalClock::Hlc.new(node: '???', now: Time.current.to_i)
    end
  end
end

