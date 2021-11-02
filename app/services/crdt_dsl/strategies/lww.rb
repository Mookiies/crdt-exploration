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
        return self unless new_register.timestamp >= timestamp

        new_register
      end
    end
  end
end
