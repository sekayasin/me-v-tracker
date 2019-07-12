require "helpers/csv_download_helpers"

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  preference = { "default_directory": DownloadHelpers::PATH.to_s }
  options.add_preference(:download, preference)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.default_driver = Capybara.javascript_driver = :chrome
