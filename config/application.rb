require_relative "boot"
require "csv"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module VofTracker
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << "#{Rails.root}/app/exceptions"
    config.autoload_paths << "#{Rails.root}/app/controllers/helpers"
    config.autoload_paths << "#{Rails.root}/app/models/observers"
    config.autoload_paths << "#{Rails.root}/app/serializers"
    config.cache_store = :redis_store, ENV["REDIS_URL"], { expires_in: 90.minutes }
    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.delivery_method = :mailgun
    config.action_mailer.mailgun_settings = {
      api_key: ENV['MAILGUN_API_KEY'],
      domain: ENV['MAILGUN_DOMAIN_NAME'],
    }
    Dir.chdir("#{Rails.root}/app/models/observers") do
      config.active_record.observers = Dir["*_observer.rb"].collect {|ob_name| ob_name.split(".").first}
    end
    config.active_record.time_zone_aware_types = [:datetime, :time]
  end
end

