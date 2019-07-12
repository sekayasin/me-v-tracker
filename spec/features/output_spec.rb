require "rails_helper"
require "spec_helper"

xdescribe "Output test" do
  before(:all) do
    @assessment = create(:assessment)
  end

  after(:all) do
    @assessment.delete
    clear_session
  end

  before(:each) do
    stub_andelan
    stub_current_session
    visit("/content_management")
    wait_for_ajax
  end

  after(:each) do
  end

  xfeature "view outputs" do
    scenario "a user should be able to navigate to the output page" do
      click_link("display_output")
      expect(page).to have_content(@assessment.name)
      expect(page).to have_content(@assessment.description)
      expect(page).to have_content(@assessment.framework.name)
    end

    scenario "non admin should not see admin actions" do
      click_link("Duyile Oluwatomi")
      click_link("Logout")
      visit("/login")
      stub_andelan_non_admin
      stub_current_session_non_admin
      visit("/content_management")
      click_link("display_output")
      expect(page).not_to have_selector(".icon_wrapper")
      expect(page).not_to have_selector("i.edit-output-modal")
      expect(page).not_to have_selector(".icon-delete")
    end
  end

  xfeature "add outputs" do
    scenario "a user should be able to add an output" do
      click_link("display_output")
      wait_for_ajax
      page.find("span.icon.menu-open").click
      click_on("Add Outcome")
      within("#output-modal") do
        fill_in("assessment-name-id", with: "Test assessment")
        fill_in("assessment-description", with: "My assesssment description")
        fill_in("assessment-expectation", with: "My assesssment expectation")
        fill_in("context", with: "Context of my assessment")
        fill_in("N/R", with: "Didnt attempt any")
        fill_in("Below Expectations", with: "Output Below Expectations")
        fill_in("At Expectations", with: "Output Meets Expectations")
        fill_in("Exceeds Expectations", with: "Output Exceeds Expectations")
        framework = page.all("div.select-wrapper")[0].click
        sleep 4
        framework.find("li:nth-child(3)").click
        wait_for_ajax
        criteria = page.all("div.select-wrapper")[1].click
        criteria.find("li:nth-child(3)").click
        click_button("add-output-save-button")
      end
      expect(page).to have_content("Test assessment")
    end
  end

  xfeature "edit outputs" do
    scenario "a user should be able to edit an output" do
      click_link("display_output")
      wait_for_ajax
      page.all("i.edit-output-modal").first.click
      within("#output-modal") do
        fill_in("assessment-name-id", with: "Editted test assessment")
        fill_in("assessment-description", with: "My edited description")
        fill_in("assessment-expectation", with: "My editted expectation")
        fill_in("context", with: "Context of my assessment")
        fill_in("N/R", with: "Didnt attempt any")
        fill_in("Below Expectations", with: "Output Below Expectations")
        fill_in("At Expectations", with: "Output Meets Expectations")
        fill_in("Exceeds Expectations", with: "Output Exceeds Expectations")
        fill_in("N/R", with: "Didnt attempt any")
        fill_in("Below Expectations", with: "Output Below Expectations")
        fill_in("At Expectations", with: "Output Meets Expectations")
        fill_in("Exceeds Expectations", with: "Output Exceeds Expectations")
        click_button("add-output-save-button")
      end
      expect(page).to have_content("Editted test assessment")
      expect(page).to have_content("My edited description")
    end
  end

  xfeature "filter outputs" do
    scenario "a user shoiuld be able to filter outputs by frmaweork" do
      click_link("display_output")
      wait_for_ajax
      criteria = page.find("div.select-wrapper.cms_output_criteria").click
      expect(criteria).to have_no_content("Quantity")
      framework = page.find("div.select-wrapper.cms_output_framework").click
      framework.find("li:nth-of-type(2)")
      wait_for_ajax
      expect(page).to have_content("Quality")
      expect(page).to have_content("Quantity")
    end

    scenario "a user should be able to filter outputs by framework criteria" do
      click_link("display_output")
      wait_for_ajax
      table_filter = page.find("div.select-wrapper.cms_output_framework").click
      table_filter.find("li", text: /Output Quality/i).click
      wait_for_ajax
      criteria = page.find("div.select-wrapper.cms_output_criteria").click
      criteria.find("li", text: /Quantity/i).click
      expect(page).to have_content("Project Management")
      expect(page).to have_no_content(@assessment.name)
    end
  end
end
