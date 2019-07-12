require "rails_helper"
require "spec_helper"

describe "Criteria test" do
  before :all do
    @framework1 = create :framework
    @criterium1 = create :criterium
    @framework_criterium1 = create(:framework_criterium, framework: @framework1,
                                                         criterium: @criterium1)

    @framework2 = create :framework
    @criterium2 = create :criterium
    @framework_criterium2 = create(:framework_criterium, framework: @framework2,
                                                         criterium: @criterium2)
    criteria_points = {
      very_satisfied: 2,
      satisfied: 1,
      neutral: 0,
      unsatisfied: -1,
      very_unsatisfied: -2
    }

    criteria_points.each do |context, value|
      Point.create(context: context.to_s.titleize, value: value)
    end
  end

  feature "admin edit/add/archive criterion" do
    before(:each) do
      stub_admin
      stub_current_session
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/curriculum")
    end

    scenario "user should be able to edit criterion info" do
      page.find("a[href='#criteria-panel']").click
      sleep 1
      page.all(".edit-icon").first.click
      within(".edit-criterion-modal") do
        fill_in("criterium_edit_name", with: "Edit existing Criterium")
        fill_in("criterium_edit_description", with: "This is a description")
        fill_in("criterium_edit_context", with: "This is a context")
        fill_in("criterium_edit_satisfied", with: "This is a metric")
        fill_in("criterium_edit_very_satisfied", with: "This is a metric")
        fill_in("criterium_edit_neutral", with: "This is a metric")
        fill_in("criterium_edit_unsatisfied", with: "This is a metric")
        fill_in("criterium_edit_very_unsatisfied", with: "This is a metric")
        click_button "Save"
      end
      wait_for_ajax
      expect(page).to have_content("Edit existing Criterium")
    end

    scenario "user should be able to create new criterion" do
      page.find("a[href='#criteria-panel']").click
      page.find(".add-criterion-btn").click
      within(".add-criterion-modal") do
        fill_in("criterium_name", with: "New Criterium")
        first(".mdl-js-checkbox").click
        fill_in("criterium_description", with: "This is a description")
        click_button "Save"
      end

      expect(page).to have_content("Criterion Successfully created")
    end

    scenario "user shouldn't be able to submit blank name or description" do
      page.find("a[href='#criteria-panel']").click
      page.find(".add-criterion-btn").click
      within(".add-criterion-modal") do
        click_button "Save"
      end

      expect(page.has_css?(".add-criterion-modal"))
    end

    scenario "user shouldn't be able to submit blank framework" do
      page.find("a[href='#criteria-panel']").click
      page.find(".add-criterion-btn").click
      within(".add-criterion-modal") do
        fill_in("criterium_name", with: "New Criterium")
        fill_in("criterium_description", with: "This is a description")
        click_button "Save"
      end
      expect(page).to have_content("Please select a framework")
    end

    scenario "admin should successfully archive criterion" do
      sleep 1
      page.find("a[href='#criteria-panel']").click
      sleep 1
      first(".archive-icon").click
      sleep 1
      find("input#confirm-delete-criteria").click
      expect(page).to have_content(
        "Criterion archived successfully"
      )
    end
  end

  feature "non admin should not be able archive a criterion" do
    before(:each) do
      stub_andelan_non_admin
      stub_current_session_non_admin
      visit("/")
      find("a.dropdown-input").click
      find("ul#index-dropdown li a.dropdown-link").click
      find("img.proceed-btn").click
      visit("/curriculum")
    end

    scenario "non admin should not be able archive a criterion" do
      sleep 1
      page.find("a[href='#criteria-panel']").click
      sleep 1
      expect(page).not_to have_button("archive-icon")
    end
  end

  xfeature "filter criteria" do
    scenario "user should be able to filter by framework" do
      framework = page.find("div.select-wrapper.cms_framework_class").click
      framework.find("li:nth-of-type(2)").click
      wait_for_ajax
      expect(page).to have_content("Quality")
      expect(page).to have_content("Quantity")
    end
  end

  xfeature "restrict non admins from edit, delete and add actions" do
    scenario "non admin should not have admin access" do
      click_link("Duyile Oluwatomi")
      click_link("Logout")
      visit("/login")
      stub_andelan_non_admin
      stub_current_session_non_admin
      visit("/content_management")
      find("li.criteria-tab.tab").click
      expect(page).not_to have_selector(".icon-edit.edit-criterium")
      expect(page).not_to have_selector(".icon-delete")
      expect(page).not_to have_selector(".icon_wrapper")
      clear_session
    end
  end

  xfeature "view criteria tab" do
    scenario "user should see created criteria names" do
      expect(page).to have_content(@criterium1.name)
      expect(page).to have_content(@criterium2.name)
    end

    scenario "user should see criteria descriptions" do
      expect(page).to have_content(@criterium1.description)
      expect(page).to have_content(@criterium2.description)
    end

    scenario "user should see criteria frameworks" do
      framework_name1 = @criterium1.frameworks[0].name
      framework_name2 = @criterium2.frameworks[0].name
      expect(page).to have_content(framework_name1)
      expect(page).to have_content(framework_name2)
    end
  end
end
