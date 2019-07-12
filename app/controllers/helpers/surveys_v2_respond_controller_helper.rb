module SurveysV2RespondControllerHelper
  include SurveysV2Exceptions

  def build_survey_response(id)
    SurveyResponse.create!(new_survey_id: id, respondable: get_respondable)
  end

  def clear_previous_response(new_res_id, survey_id)
    SurveyResponse.where.not(id: new_res_id).find_by(
      respondable: get_respondable,
      new_survey_id: survey_id
    ).try(:destroy)
  end

  def build_responses(survey_id, res_id, response_data)
    survey_questions = get_survey_questions(survey_id)
    build_survey_option_responses(survey_questions, response_data, res_id)
    build_option_grid_responses(survey_questions, response_data, res_id)
    build_survey_value_responses(survey_questions, response_data, res_id)
  end

  private

  def get_survey_questions(survey_id)
    survey = NewSurvey.find(survey_id)
    section_id = SurveySection.where(new_survey_id: survey.id)
    SurveyQuestion.where(survey_section_id: section_id)
  end

  def get_respondable
    email = session[:current_user_info][:email].to_s
    Bootcamper.find_by(email: email)
  end

  def create_option_response(question_type, option_id, question_id, res_id)
    SurveyOptionResponse.create!(
      question_type: question_type,
      option_id: option_id,
      question_id: question_id,
      survey_response_id: res_id
    )
  end

  def create_scale_response(question_type, value, question_id, res_id)
    SurveyScaleResponse.create!(
      question_type: question_type,
      value: value,
      question_id: question_id,
      survey_response_id: res_id
    )
  end

  def create_date_response(question_type, value, question_id, res_id)
    SurveyDateResponse.create!(
      question_type: question_type,
      value: value,
      question_id: question_id,
      survey_response_id: res_id
    )
  end

  def create_time_response(question_type, value, question_id, res_id)
    SurveyTimeResponse.create!(
      question_type: question_type,
      value: value,
      question_id: question_id,
      survey_response_id: res_id
    )
  end

  def create_paragraph_response(question_type, value, question_id, res_id)
    SurveyParagraphResponse.create!(
      question_type: question_type,
      value: value,
      question_id: question_id,
      survey_response_id: res_id
    )
  end

  def build_option_grid_responses(survey_questions, response_data, res_id)
    survey_questions.each do |survey_question|
      response = response_data["question_#{survey_question.id}"]
      questionable_type = survey_question.questionable_type
      next unless (questionable_type == "SurveyOptionQuestion") && response

      build_multi_grid_response(response, res_id)
      build_checkbox_grid_response(response, res_id)
    end
  end

  def build_survey_option_responses(survey_questions, response_data, res_id)
    survey_questions.each do |survey_question|
      response = response_data["question_#{survey_question.id}"]
      questionable_type = survey_question.questionable_type
      next unless (questionable_type == "SurveyOptionQuestion") && response

      build_multiple_choice_response(response, res_id)
      build_checkbox_response(response, res_id)
      build_select_response(response, res_id)
      build_picture_option_response(response, res_id)
      build_picture_checkbox_response(response, res_id)
    end
  end

  def build_multi_grid_response(response, res_id)
    question_type = "SurveyMultigridOptionQuestion"
    return unless response["question_type"] == question_type

    response_ids = response["choice_response"]
    response_ids.each do |response_id|
      SurveyGridOptionResponse.create!(
        question_type: "SurveyMultigridOptionQuestion",
        row_id: response_id[0],
        col_id: response_id[1],
        question_id: response["question_id"],
        survey_response_id: res_id
      )
    end
  end

  def build_checkbox_grid_response(response, res_id)
    return unless response["question_type"] == "SurveyMultigridCheckboxQuestion"

    response_ids = response["checkbox_response"]
    response_ids.each do |response_id|
      SurveyGridOptionResponse.create!(
        question_type: "SurveyMultigridCheckboxQuestion",
        row_id: response_id[0],
        col_id: response_id[1],
        question_id: response["question_id"],
        survey_response_id: res_id
      )
    end
  end

  def build_survey_value_responses(survey_questions, response_data, res_id)
    survey_questions.each do |survey_question|
      response = response_data["question_#{survey_question.id}"]
      next unless response

      build_survey_scale_response(response, res_id)
      build_survey_paragraph_response(response, res_id)
      build_survey_date_response(response, res_id)
      build_survey_time_response(response, res_id)
    end
  end

  def build_multiple_choice_response(response, res_id)
    question_type = "SurveyMultipleChoiceQuestion"
    return unless response["question_type"] == question_type

    option_id = response["option_id"]
    create_option_response(question_type,
                           option_id, response["question_id"], res_id)
  end

  def build_checkbox_response(response, res_id)
    return unless response["question_type"] == "SurveyCheckboxQuestion"

    checkbox_ids = response["checkbox_ids"]
    checkbox_ids.each do |checkbox_id|
      create_option_response(response["question_type"],
                             checkbox_id, response["question_id"], res_id)
    end
  end

  def build_select_response(response, res_id)
    question_type = "SurveySelectQuestion"
    return unless response["question_type"] == question_type

    option_id = response["dropdown_id"]
    create_option_response(question_type,
                           option_id, response["question_id"], res_id)
  end

  def build_picture_option_response(response, res_id)
    question_type = "SurveyPictureOptionQuestion"
    return unless response["question_type"] == question_type

    option_id = response["picture_id"]
    create_option_response(question_type,
                           option_id, response["question_id"], res_id)
  end

  def build_picture_checkbox_response(response, res_id)
    question_type = "SurveyPictureCheckboxQuestion"
    return unless response["question_type"] == question_type

    picture_checkbox_ids = response["picture_checkbox_ids"]
    picture_checkbox_ids.each do |picture_checkbox_id|
      create_option_response(question_type, picture_checkbox_id,
                             response["question_id"], res_id)
    end
  end

  def build_survey_scale_response(response, res_id)
    question_type = "SurveyScaleQuestion"
    return unless response["question_type"] == question_type

    value = response["value"]
    create_scale_response(question_type,
                          value, response["question_id"], res_id)
  end

  def build_survey_paragraph_response(response, res_id)
    question_type = "SurveyParagraphQuestion"
    return unless response["question_type"] == question_type

    paragraph_value = response["value"]
    create_paragraph_response(question_type,
                              paragraph_value, response["question_id"], res_id)
  end

  def build_survey_date_response(response, res_id)
    question_type = "SurveyDateQuestion"
    return unless response["question_type"] == question_type

    date = response["value"]
    date_value = date.nil? ? "" : Date.strptime(date, "%m/%d/%Y")
    create_date_response(question_type,
                         date_value, response["question_id"], res_id)
  end

  def build_survey_time_response(response, res_id)
    question_type = "SurveyTimeQuestion"
    return unless response["question_type"] == question_type

    time = response["value"]
    value = time.nil? ? "" : Time.strptime(time, "%I : %M %P").strftime("%H:%M")
    create_time_response(question_type,
                         value, response["question_id"], res_id)
  end
end
