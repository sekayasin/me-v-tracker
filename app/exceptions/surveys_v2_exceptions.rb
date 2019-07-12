module SurveysV2Exceptions
  class SurveyException < StandardError
    def initialize(message)
      super({ error: { survey: { message: message } } }.to_json)
    end
  end

  class SurveyQuestionException < StandardError
    def initialize(message, question)
      q = question.is_a?(SurveyQuestion) ? question.attributes : question
      section = q["section"]
      position = q["position"]
      super({
        error: {
          survey_question: {
            message: message,
            section: section,
            position: position
          }
        }
      }.to_json)
    end
  end

  class SurveyOptionException < SurveyQuestionException; end
end
