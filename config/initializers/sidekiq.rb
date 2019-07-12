require 'sidekiq'
require 'sidekiq/web'

redis_con = proc {
  Redis.current
}

# username and password to view sidekiq web UI
Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ["vof-sidekiq", "NXTiborav7!#"]
end

Sidekiq.configure_server do |config|
  schedule_file = "config/schedule.yml"
  config.redis = ConnectionPool.new(size: 20, &redis_con)

  if File.exist?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new(size: 20, &redis_con)
end