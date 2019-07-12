require "capybara"

module Helpers
  def create_respond_bootcamper
    center = create(:center)
    program = create(:program)
    @bootcamper = create(:bootcamper)
    cycle_center = create(:cycle_center, :ongoing, center: center)
    create :learner_program,
           camper_id: @bootcamper[:camper_id],
           cycle_center: cycle_center,
           program_id: program.id
  end

  def prepare_optional_question
    survey_section_one = create(:survey_section, new_survey_id: @survey.id)
    survey_section_two = create(:survey_section, new_survey_id: @survey.id)
    survey_section_three = create(:survey_section, new_survey_id: @survey.id)
    survey_ques_option = create(:survey_option_question,
                                question_type: "SurveyMultipleChoiceQuestion")
    create_sectional_rules(survey_ques_option, survey_section_three)
    create(:survey_question,
           survey_section_id: survey_section_one.id,
           questionable_type: "SurveyOptionQuestion",
           questionable_id: survey_ques_option.id)

    create(:survey_option, :with_row_option,
           survey_option_question_id: survey_ques_option.id)
    create(:survey_question, survey_section_id: survey_section_two.id,
                             questionable_id: @survey.id,
                             questionable_type: "SurveyParagraphQuestion")
    create(:survey_question,
           survey_section_id: survey_section_two.id,
           questionable_id: @survey.id,
           questionable_type: "SurveyDateQuestion")
    create(:survey_date_question, id: @survey.id)
    create(:survey_question,
           survey_section_id: survey_section_three.id,
           questionable_id: @survey.id,
           questionable_type: "SurveyTimeQuestion")
  end

  def create_sectional_rules(survey_ques_option, survey_section_three)
    test_option = create(:survey_option,
                         :with_row_option,
                         survey_option_question_id: survey_ques_option.id)
    create(:survey_section_rule,
           survey_section_id: survey_section_three.id,
           survey_option_id: test_option.id)
  end

  def answer_multichoice_question
    within ".answer:nth-child(1)" do
      find("input", visible: false).click
    end
    expect(page).to have_selector(".time-wrapper")
    within ".answer:nth-child(2)" do
      find("input", visible: false).click
    end
  end

  def answer_question(position)
    within ".answer:nth-child(#{position})" do
      find("input", visible: false).click
    end
    find("#next-preview").click
    find(".txt").set("My Paragraph")
    find(".select-date").set("02/12/2019")
    find(".respond-submit-btn").click
  end

  def submit_user_response
    within ".answer:nth-child(1)" do
      find("input", visible: false).click
    end
    within ".time-wrapper" do
      first(".display-time").set("10")
      find(".display-time:nth-child(2)").set("59")
    end
    find("#next-preview").click
    find(".txt").set("My Paragraph")
    find(".select-date").set("02/12/2019")
    find(".respond-submit-btn").click
  end
end
