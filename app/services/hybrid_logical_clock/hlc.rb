# frozen_string_literal: true

module HybridLogicalClock
  class Hlc
    include Comparable

    # In a far future, we may need to break the format. This gives us the opportunity to.
    VERSION = 'v01'

    private_constant :VERSION
    attr_reader :ts, :count, :node

    # @param now [Integer] the current time
    # @param count [Integer] the current count
    # @param node [String] a unique identifier for a node
    def initialize(node:, now: Time.current.to_i, count: 0)
      raise TypeError, 'now expects an integer' unless now.is_a?(Integer)
      raise TypeError, 'count expects an integer' unless count.is_a?(Integer)
      raise TypeError, 'node expects a string' unless node.is_a?(String)

      @ts = now
      @count = count
      @node = node
    end

    # @param serialized_hybrid_clock [String]
    def self.unpack(serialized_hybrid_clock)
      ts, count, node = serialized_hybrid_clock.split(':')
      new(now: Integer(ts, 36), count: Integer(count, 36), node: node)
    end

    def pack
      "#{ts.to_s(36).rjust(15, '0')}:#{count.to_s(36).rjust(5, '0')}:#{node}:#{VERSION}"
    end

    # @param other [HybridClockService]
    def <=>(other)
      if ts == other.ts
        return node <=> other.node if count == other.count

        return count <=> other.count
      end

      ts <=> other.ts
    end

    def increment(now: Time.current.to_i)
      if now > ts
        @ts = now
        @count = 0
        return self
      end

      @count += 1
      self
    end

    # @param remote_hybrid_clock [HybridClockService] the remote HybridClockService
    # @param now [Integer] the current time
    def receive(remote_hybrid_clock, now: Time.current.to_i)
      raise TypeError, 'now expects an integer' unless now.is_a?(Integer)

      if now > ts && now > remote_hybrid_clock.ts
        @ts = now
        @count = 0
      elsif ts == remote_hybrid_clock.ts
        @count = [count, remote_hybrid_clock.count].max + 1
      elsif ts > remote_hybrid_clock.ts
        @count += 1
      else
        @ts = remote_hybrid_clock.ts
        @count = remote_hybrid_clock.count + 1
      end

      self
    end
  end
end
