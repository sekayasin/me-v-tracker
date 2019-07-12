require "rails_helper"
require "spec_helper"
require_relative "../support/helpers.rb"
require_relative "../support/survey_v2_feature_helper"
require_relative "../helpers/survey_v2_create_spec_helper"

describe "Survey 2.0 page test without survey" do
  before :all do
    create_survey_bootcamper
  end

  feature "Learner Survey 2.0 Page" do
    before(:each) do
      stub_different_users
      visit("/surveys")
    end

    scenario "redirects to survey v2 page" do
      find("#surveys-v2-btn").click
      expect(current_path).to eq("/surveys-v2")
      expect(page).to have_content("Surveys")
    end
  end

  feature "LFA/Observer View" do
    before(:each) do
      clear_session
      stub_andelan_non_admin
      stub_current_session_non_admin
      visit("/surveys-v2")
    end

    scenario "it redirects to index route if not a learner or Admin" do
      expect(current_path).to eq("/")
    end
  end

  feature "Admin View" do
    before(:each) do
      stub_admin_data_success
      stub_andelan
      stub_current_session
      select_program
    end

    scenario "view setup page" do
      find("#new-survey-btn").click
      expect(current_path).to eq("/surveys-v2/setup")
      assert_content %W(Create\ a\ Survey Add\ description)
    end

    scenario "expect to see create a survey when there is no survey" do
      expect(page).to have_content("Create a Survey")
    end
  end
end

describe "Survey 2.0 page test with surveys" do
  before(:each) do
    stub_admin_data_success
    stub_andelan
    stub_current_session
    select_program
  end

  before :all do
    @survey = create(:new_survey, survey_creator: "oluwatomi.duyile@andela.com")
    @new_survey = create(
      :new_survey,
      :draft,
      survey_creator: "oluwatomi.duyile@andela.com"
    )
  end

  feature "Admin View surveys" do
    scenario "expect to see create a survey when there is no survey" do
      expect(page).to have_content("Create a Survey")
    end
  end

  feature "Create new survey" do
    before_each_go_to_surveys_page

    initialize_survey_ui

    survey_create_question_helper("published")

    survey_validate_blanks_on_share_or_draft
  end

  it "New survey? only save draft option is availaible on the modal" do
    visit("/surveys-v2/#{@new_survey.id}/edit")
    find("#survey-share-btn").click
    sleep 1
    expect(page).to have_css("#survey-save-progress")
  end

  it "Edit draft survey? survey should retain start end dates " do
    visit("/surveys-v2/#{@new_survey.id}/edit")
    sleep 1
    find("#survey-share-btn").click
    expect(find_field("From Date").value).to eq "28 Jun 2019 00:00"
  end

  it "Edit draft survey? survey should retain end dates " do
    visit("/surveys-v2/#{@new_survey.id}/edit")
    sleep 1
    find("#survey-share-btn").click
    expect(find_field("To Date").value).to eq "29 Jun 2019 00:00"
  end

  it "Survey published? hide saveDraft button" do
    visit("/surveys-v2/#{@survey.id}/edit")
    expect(page).not_to have_css("#survey-save-progress")
  end
end
