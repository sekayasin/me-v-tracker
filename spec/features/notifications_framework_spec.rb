require "rails_helper"
require "spec_helper"
require "helpers/notification_framework_helpers"

describe "Notification Framework test" do
  include NotificationFrameworkHelpers
  before(:all) do
    set_up
  end
  before(:each) do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    # find("a#skip-tour-btn").click
  end

  after(:all) do
    tear_down
  end

  feature "Access current logged in user notification" do
    scenario "users should be able to view created notification" do
      find("a.notifications-trigger").click
      find(".notifications-pane")
      @notification_group.each do |group|
        expect(page).to have_content(group.name.upcase)
      end
    end
  end

  feature "Clear Notification" do
    scenario "users should be able to archive a notification" do
      find("a.notifications-trigger").click
      sleep 1

      find(".notification-box.#{@notification_group[0].name.gsub(/\s+/, '-')}
      .notification span.close-button").click

      expect(page).to have_no_content(
        @notification_group[0].name.upcase
      )
    end

    scenario "users should be able to archive groups of notifications" do
      find("a.notifications-trigger").click
      sleep 1

      find(".notification-box:nth-of-type(1)
      button.clear-notification-btn").click

      find(".notification-box:nth-of-type(1)
      button.clear-notification-btn").click

      expect(page).to have_content("All caught up :)")
    end

    scenario "users should be able to view archived notifications" do
      find("a.notifications-trigger").click
      find("span.switch-notification-class").click

      @notification_group.each do |group|
        expect(page).to have_content(group.name.upcase)
      end
    end
  end
end
