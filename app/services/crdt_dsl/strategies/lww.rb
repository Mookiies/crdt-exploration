# frozen_string_literal: true

module CrdtDsl
  module Strategies
    class Lww
      attr_reader :value, :timestamp

      def initialize(value:, timestamp:)
        raise ArgumentError, 'timestamp must be present' unless timestamp.present?

        @value = value
        @timestamp = timestamp
      end

      def merge(new_register)
        # return self unless new_register.timestamp >= timestamp
        return self unless newer_timestamp?(new_register.timestamp, timestamp)

        new_register
      end

      private

      def newer_timestamp?(change_ts, prev_ts)
        return true if prev_ts.nil?

        parsed_change = DateTime.parse(change_ts)
        parsed_prev = DateTime.parse(prev_ts)
        parsed_change - parsed_prev >= 0
      end
    end
  end
end
