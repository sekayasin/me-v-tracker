class SurveysV2RespondController < ApplicationController
  skip_before_action :redirect_non_andelan
  include SurveysV2RespondControllerHelper

  def create
    survey_id = parse(params[:survey_id])
    survey_data = parse(params[:survey_responses])
    new_response = build_survey_response(survey_id)
    build_responses(survey_id, new_response.id, survey_data)
  rescue SurveyException, JSON::ParserError => e
    Bugsnag.custom_notify(e)
    new_response.destroy
  ensure
    if e
      render json: e.message, status: 400
    else
      clear_previous_response(new_response.id, survey_id)
      render json: { message: "Response Successfully Submitted" }, status: 201
    end
  end

  def edit
    @survey_response = SurveyResponse.find_by(new_survey_id: params[:survey_id])
    render json: @survey_response,
           include: %w(
             survey_date_responses
             survey_grid_option_responses
             survey_option_responses
             survey_paragraph_responses
             survey_time_responses
             survey_scale_responses
           ), status: 200
  end
end
