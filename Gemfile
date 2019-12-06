source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 5.0.3"
# Ruby Version
ruby "2.4.1"
# Use postgresql as the database for Active Record
gem "pg", "0.20.0"

# Use fog to access GCP buckets
gem "fog-google"
gem "fog-aws"

# For processing images before upload
gem 'image_processing', '~>1.0'

# Use telephone_number to validate phone numbers
gem "telephone_number"
# Use Puma as the app server. versions higher than this have memory leaks
# https://github.com/puma/puma/issues/1600
# Use Puma as the app server
gem "puma", "3.12.2"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 4.2"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use fontawesome for icons
gem "font-awesome-rails"
# Use jquery as the JavaScript library
gem "jquery-rails"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
gem "redis", '~> 3.0'
gem "redis-rails"
gem "redis-namespace"
gem "mock_redis"
# Rails observer (removed from core in Rails 4.0)
gem 'rails-observers'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem "activerecord-session_store"

# For jwt authentication
gem "jwt"

# For flash messages
gem "puffly"

# For env variables
gem "figaro"

# For importing CSV files
gem "roo", "~> 2.7.1"

# add jQuery support for Turbolinks
gem "jquery-turbolinks"

# add jquery validation
gem "jquery-validation-rails"

# add jquery autocomplete
gem "jquery-ui-rails"

# add kaminari for pagination
gem "kaminari"

# add addressable for URI validation
gem "addressable"

# add cloudinary to serve static images
gem 'cloudinary'

# add chartjs for data visualization
gem 'chart-js-rails', "0.1.4"

# add paranoia to avoid permanent deletion of records
gem 'paranoia', '~> 2.4', '>= 2.4.1'

# Use Httparty to make HTTP requests to external API
gem 'httparty'

gem "listen", "~> 3.0.5"

# Use the business_time to get working days
gem 'business_time', "0.9.3"

gem 'logstasher'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platform: :mri
  gem "faker"
  gem "pry"
  gem 'rubocop', '~> 0.73.0', require: false
  gem 'action-cable-testing'
end

# add bugsnag for error reporting

group  :sandbox, :production, :staging do
  gem "bugsnag"
end

group :test do
  gem "capybara"
  gem 'webdrivers', '~> 3.0'
  gem "codeclimate-test-reporter", "~> 1.0.0"
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "rack_session_access"
  gem "rails-controller-testing"
  gem "rspec-rails", "~> 3.5"
  gem "selenium-webdriver", "~> 3.4.3"
  gem "should_not"
  gem "shoulda-matchers", "~> 3.1"
  gem "simplecov"
  gem 'rspec-json_expectations'
  gem 'rspec-retry'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console", ">= 3.3.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  # Analyses and process the time for various renderings, queries and DOM loading
  gem "rack-mini-profiler"
  # Looks and points out n+1 queries that should be re-factored. Look here: https://github.com/flyerhzm/bullet
  gem "bullet"
  gem 'rails-erd'
end

group :sandbox do
  gem "meta_request"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i(mingw mswin x64_mingw jruby)

# gem for jobs and cron tasks
gem 'sidekiq'
gem "sidekiq-cron", "~> 1.0"

# gem for serializer
gem 'active_model_serializers', '~> 0.10.2'

# Gem for mailgun services
gem 'mailgun-ruby'

#Gem for creating and managing database views
gem "scenic"

