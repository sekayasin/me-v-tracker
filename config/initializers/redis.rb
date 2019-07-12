unless Rails.env.test?
  Redis.current = Redis::Namespace.new("vof", redis: Redis.new)
else
  Redis.current = Redis::Namespace.new("vof", redis: MockRedis.new)
end
