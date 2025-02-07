# frozen_string_literal: true

module HttpHealthCheck
  module Probes
    class Sidekiq
      include ::HttpHealthCheck::Probe

      TTL_SEC = 3
      MAGIC_NUMBER = 42

      def initialize(sidekiq: ::Sidekiq)
        @sidekiq_module = sidekiq
      end

      def probe(_env)
        @sidekiq_module.redis do |conn|
          conn.setex(meta[:redis_key], TTL_SEC, MAGIC_NUMBER)
          probe_ok
        end
      end

      def meta
        @meta ||= { redis_key: redis_key }
      end

      private

      def redis_key
        @redis_key ||= ['sidekiq-healthcheck', ::Socket.gethostname, ::Process.pid].join('::')
      end
    end
  end
end
