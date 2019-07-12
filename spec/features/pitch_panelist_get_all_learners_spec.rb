require "rails_helper"
require "spec_helper"
require "helpers/pitch_helper.rb"

describe "Pitch setup page" do
  include CreatePitchHelper
  before :all do
    create_seed_data
  end

  after :all do
    clear_seed_data
  end

  feature "Ongoing pitch" do
    before(:each) do
      pitch_setup(stub_andelan_panelist, stub_current_session_panelist)
    end

    scenario "panellist gets all learners to pitch he/she is invited to" do
      expect(page).to have_css(".panelist-wrapper")
      expect(page).to have_css(".panelist-cards")
      expect(page).to have_css(".panelist-content")
      expect(@learners_pitch.pitch_id).to eq @pitch.id
      expect(@learners_pitch.blank?).to be false
    end
  end

  feature "Panellist not invited to pitch" do
    before(:each) do
      clear_session
      pitch_setup(stub_andelan_non_admin_two, stub_current_session)
    end

    scenario "it redirects to not found if not panelist" do
      expect(page).to have_css(".not-found")
    end
  end

  feature "Ongoing pitch for Admin panelist/Learner tab" do
    before(:each) do
      clear_session
      pitch_setup(stub_admin, stub_current_session_admin)
    end
    scenario "Admin gets all learners to a pitch" do
      expect(page).to have_css(".persona-name")
      expect(page).to have_css(".persona-mail")
      expect(@learners_pitch.pitch_id).to eq @pitch.id
      expect(@learners_pitch.blank?).to be false
    end

    scenario "panellist gets all learners to pitch he/she is invited to" do
      expect(page).to have_css(".pitch-persona-card")
      expect(page).to have_css(".persona-card-body")
    end
  end

  feature "Learner ratings page" do
    before(:each) do
      pitch_setup(stub_andelan_panelist, stub_current_session_panelist)
    end
    scenario "Admin/ panelist should be redirected if its not the demo date" do
      page.all(".panelist-card").first.click
      expect(page).
        to have_content("You can only rate a learner during the demo")
    end
  end

  feature "Panellist rate learner" do
    before :all do
      create_pitch("efe.love@andela.com", Date.today)
    end

    before(:each) do
      clear_session
      pitch_setup(stub_andelan_panelist, stub_current_session_panelist)
    end

    scenario "without filling all fields" do
      test_incomplete_ratings
    end

    scenario "filling all fields correctly" do
      setup_complete_ratings
      expect(page).
        to have_content("Rated")
    end

    scenario "see the learner rating modal" do
      first(".rated-learner-message").click
      test_learner_modal_contents
      expect(page).to have_css(".panelist-comment")
    end
  end

  feature "Admin invited as a Panellist can rate learner" do
    before :all do
      create_pitch("kingsley.eneja@andela.com", Date.today)
    end
    before(:each) do
      clear_session
      pitch_setup(stub_admin_panelist, stub_current_session_admin_panelist)
      find("a#ratings-tab").click
    end

    scenario "without filling all fields" do
      test_incomplete_ratings
    end

    scenario "filling all fields correctly" do
      setup_complete_ratings
      find("a#ratings-tab").click
      expect(page).
        to have_content("Rated")
    end
  end
end
