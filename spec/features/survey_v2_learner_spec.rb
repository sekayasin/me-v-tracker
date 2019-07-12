require "rails_helper"
require "spec_helper"

describe "Learner surveys page" do
  before :all do
    @learner_program = create_survey_bootcamper
    @survey = create(:new_survey, :published)
    @survey.update(cycle_centers: [@learner_program.cycle_center])
    SurveyV2NotificationJob.perform_now(
      @survey.id,
      @survey.start_date,
      @learner_program.cycle_center
    )
  end

  feature "Learner view" do
    before :each do
      stub_different_users
      visit("/surveys-v2")
    end

    scenario "can view survey card" do
      find(".survey-card")
      expect(page).to have_content(@survey.title.capitalize)
    end

    scenario "can view survey notification" do
      find(".notification-icon").click
      expect(page).to have_content("Hello! You have received a new survey")
      find(".survey-link")
    end
  end
end

describe "Learner surveys page pagination" do
  before(:each) do
    stub_different_users
    visit("/surveys-v2")
  end
  before :all do
    @learner_program = create_survey_bootcamper
    @survey = create_list(:new_survey, 40, :published)
    @survey.each do |survey|
      survey.update(cycle_centers: [@learner_program.cycle_center])
    end
  end

  feature "Learner can click on pagination button" do
    scenario "Learner should be able to see a pagination control" do
      expect(page).to have_css(".pagination-control")
      expect(page).to have_css(".main-pages")
      expect(page).to have_css(".page.active-page")
    end

    scenario "Learner should be able to navigate between pages" do
      next_button = find(".next")
      previous_button = find(".prev")
      sleep 1
      next_button.click
      next_button.click
      next_button.click
      previous_button.click
      previous_button.click
      previous_button.click

      expect(page).to have_css(".prev-next.grey-out")
      expect(page).to have_css("#survey-title")
      expect(page).to have_css("#rem-time")
    end
  end
end
