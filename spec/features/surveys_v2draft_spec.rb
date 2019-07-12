require "rails_helper"
require "spec_helper"
require_relative "../support/helpers.rb"
require_relative "../support/survey_v2_feature_helper"
require_relative "../helpers/survey_v2_create_spec_helper"

describe "Survey 2.0 page test with survey drafts" do
  before :all do
    create_survey_bootcamper
  end

  before(:each) do
    stub_admin_data_success
    stub_andelan
    stub_current_session
    select_program
  end

  before :all do
    @survey = create(:survey)
  end

  feature "Create survey draft" do
    before_each_go_to_surveys_page

    initialize_survey_ui

    survey_create_question_helper("draft")

    survey_validate_blanks_on_share_or_draft
  end
end
