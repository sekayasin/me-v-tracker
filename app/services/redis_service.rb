require "json"

module RedisService
  class << self
    def set(key, value)
      return false if redis_disconnected? || value.blank?

      redis.set(key, value.to_json)
      redis.expire(key, 30.minutes.to_i)
    end

    def get(key)
      return false if redis_disconnected? || !redis.exists(key)

      JSON.parse(redis.get(key))
    end

    def delete_key(key)
      return false if redis_disconnected?
      return if key == []

      redis.del(key)
    end

    def delete_all_keys
      return false if redis_disconnected?

      redis.redis.flushdb
    end

    def search(key)
      return false if redis_disconnected?

      redis.scan(0, match: key)[1]
    end

    private

    def redis
      Redis.current
    end

    def report_bugsnag(error)
      Bugsnag.custom_notify(error)
    end

    def redis_disconnected?
      return false if !!Redis.current.redis.ping
    rescue Redis::CannotConnectError, Redis::CommandError => e
      report_bugsnag(e)
      true
    end
  end
end
