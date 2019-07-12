class SurveyQuestionSerializer < ActiveModel::Serializer
  attributes :id, :question, :description, :description_type,
             :position, :is_required, :type,
             :survey_options, :scale, :survey_section_id, :date_limits

  belongs_to :survey_section

  SURVEY_OPTIONS_TYPES = %w(
    SurveyMultigridOptionQuestion SurveyMultigridCheckboxQuestion
  ).freeze
  def survey_options
    if object.questionable_type == "SurveyOptionQuestion"
      if SURVEY_OPTIONS_TYPES.include? object.questionable[:question_type]
        {
          rows: survey_options_rows,
          columns: survey_options_columns
        }
      else
        survey_question.survey_options
      end
    end
  end

  def survey_options_columns
    survey_question.survey_options.select do |option|
      option[:option_type] == "column"
    end
  end

  def survey_options_rows
    survey_question.survey_options.select do |option|
      option[:option_type] == "row"
    end
  end

  def scale
    if object.questionable_type == "SurveyScaleQuestion"
      { min: object.questionable[:min], max: object.questionable[:max] }
    end
  end

  def date_limits
    if object.questionable_type == "SurveyDateQuestion"
      { min: object.questionable[:min], max: object.questionable[:max] }
    end
  end

  def type
    if object.questionable_type == "SurveyOptionQuestion"
      object.questionable[:question_type]
    else
      object.questionable_type
    end
  end

  def survey_question
    case object.questionable_type
    when "SurveyOptionQuestion"
      SurveyOptionQuestion.find(object.questionable_id)
    when "SurveyScaleQuestion"
      SurveyScaleQuestion.find(object.questionable_id)
    when "SurveyDateQuestion"
      SurveyDateQuestion.find(object.questionable_id)
    end
  end
end
