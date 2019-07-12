# defining a new class instead of using class eval since library isn't
# available in non-target environments
module Bugsnag
  class << self
    def custom_notify(e)
      Bugsnag.notify(e) unless Rails.env.development? || Rails.env.test?
    end
  end
end
