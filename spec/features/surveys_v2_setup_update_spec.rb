require "rails_helper"
require "spec_helper"
require_relative "../support/helpers.rb"
require_relative "../support/survey_v2_feature_helper"

describe "Survey 2.0 setup page" do
  before :each do
    # stub_admin_data_success
    stub_andelan
    stub_current_session
    select_program
    visit "/surveys-v2/setup"
  end

  feature "Delete a survey" do
    scenario "admin can delete a survey question" do
      sleep 1
      populate_question_helper("2")
      fill_in("Type Your Question...", with: "New question from me")
      fill_in("Add A Choice", with: "point")
      find(".add-choice").native.send_keys(:return)
      find("#delete-question").click
      expect(page).to have_content("Confirm Delete")
      find("#confirm-delete-survey").click
      expect(page).to have_content("Select Question Type", count: 0)
    end

    scenario "admin can delete a survey section" do
      find(".section-options .more-icon").hover
      find("#remove-section").click
      find("#confirm-delete-section").click
      expect(page).to have_no_content("SECTION", count: 0)
    end
  end

  feature "Re-order Sections" do
    before :each do
      populate_question_helper("2")
      find("#add-section-btn-0").click
    end

    after :each do
      first(".cloned-section").find("#delete-question").click
      find("#confirm-delete-survey").click
      within(".cloned-section") do
        within(".select-question") do
          expect(page).to have_content("Multiple Choices")
        end
      end
    end

    scenario "users can re-order down the survey sections" do
      reorder_survey("0", "#re-order-down-section-0")
    end

    scenario "users can re-order up the survey sections" do
      reorder_survey("1", "#re-order-up-section-1")
    end
  end

  feature "Clone section" do
    scenario "clones a survey section" do
      find(".section-title .more-icon").hover
      find("#duplicate-section").click
      assert_content %W(SECTION\ 2 Add\ Question Add\ a\ Section)
    end
  end

  feature "Link section" do
    scenario "fail to link first section to question" do
      find("#section-0 .more-icon").hover
      find("#link-question").click
      expect(page).to have_content(
        "Oops! You need a previous section to link to"
      )
    end

    scenario "click link question opens modal" do
      find("#add-section-btn-0").click
      find("#section-1 .more-icon").hover
      find("#link-question").click
      expect(page).to have_content("Link Section to Question")
    end

    scenario "link a section to a question" do
      populate_and_link_section
      expect(page).to have_content("Section successfully linked to option")
      find("#section-1 .more-icon").hover
      expect(page).to have_content("Unlink")
    end

    scenario "unlink a section from a question" do
      populate_and_link_section
      find("#section-1 .more-icon").hover
      find("#unlink-question").click
      expect(page).to have_content("Section successfully unlinked")
    end

    scenario "cannot reorder a linked section" do
      populate_and_link_section
      find("#section-1 .more-icon").hover
      find("#re-order-up-section-1").hover
      expect(page).to have_content("You cannot re-order a linked section")
    end

    scenario "cannot reorder a section containing a linked question" do
      populate_and_link_section
      find("#section-0 .more-icon").click
      find("#re-order-down-section-0").hover
      expect(page).to have_content("You cannot re-order a linked section")
    end
  end
end
