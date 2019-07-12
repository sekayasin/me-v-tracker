require "rails_helper"
require "spec_helper"

describe "Curriculum page test" do
  before(:each) do
    stub_andelan
    stub_current_session
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    visit("/curriculum")
  end

  before(:all) { page.driver.browser.manage.window.resize_to(1440, 900) }
  scenario "a modal should be displayed when edit icon is clicked" do
    page.find("a[href='#learning-outcomes-panel']").click
    first(".edit-icon").click
    expect(page.has_css?(".edit-criterion-modal"))
  end
end
