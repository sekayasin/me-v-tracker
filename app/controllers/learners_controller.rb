class LearnersController < ApplicationController
  before_action :redirect_unauthorized_learner,
                only: %i(index get_learner_technical_details)
  skip_before_action :redirect_non_andelan

  include LearnersControllerHelper

  def index
    @learner = get_learner
    @learner_programs = get_learner_programs(@learner[:camper_id])
    @learner_technical_details = get_learner_technical_details
    unless session[:current_user_info].nil?
      @personal_info = learner_details session[:current_user_info][:email]
    end
  end

  def update_learner_information
    learner = LearnerProgram.find_by(
      camper_id: params[:id],
      id: params[:learner_program_id]
    )

    if update_learner(learner, params)
      render json: { saved: true, data: get_updated_learner(learner) }
    else
      render json: { saved: false, errors: learner.bootcamper.errors }
    end
  end

  def get_learner_city
    country = params[:country].strip
    cities = Center.where(country: country).pluck(:name).uniq
    render json: cities
  end

  def get_learner_technical_details
    camper_id = get_learner[:camper_id]
    learner_technical_details = {
      alc_languages_stacks: get_alc_language_stacks(camper_id),
      preferred_languages_stacks: get_preferred_language_stacks(camper_id)
    }

    respond_to do |format|
      format.json { render json: learner_technical_details }
      format.html { learner_technical_details }
    end
  end

  def update_learner_technical_details
    camper_id = get_learner[:camper_id]
    Bootcamper.update_preferred_languages_stacks(
      camper_id,
      get_technical_details_params
    )
    render json: {
      message: "Learner technical details updated successfully",
      preferred_languages_stacks: get_preferred_language_stacks(camper_id)
    }
  rescue StandardError
    render json: {
      error: true,
      message: "Learner technical details update unsuccessful"
    }
  end

  def update_learner_personal_details
    errors = validate_personal_details(params)
    result = if errors.empty?
               finalize_personal_details_update(params)
             else
               { status: false, errors: errors }
             end
    render json: result
  end

  private

  def get_learner
    learner_email = session[:current_user_info][:email]
    learner = RedisService.get("learner_profile_#{learner_email}")
    learner = learner ? learner.deep_symbolize_keys : learner
    unless learner
      learner = Bootcamper.where(email: session[:current_user_info][:email]).
                last
      RedisService.set("learner_profile_#{learner_email}", learner)
    end
    learner
  end

  def get_learner_programs(camper_id)
    learner_programs = RedisService.
                       get("learner_profile_#{camper_id}_programs")
    if learner_programs
      learner_programs = learner_programs.map(&:symbolize_keys)
    else
      learner_programs = LearnerProgram.get_learner_programs(camper_id)
      RedisService.set("learner_profile_#{camper_id}_programs",
                       learner_programs)
    end
    learner_programs
  end

  def learner_details(email)
    learner_details = RedisService.get("learner_profile_#{email}_details")
    if learner_details
      learner_details = learner_details.deep_symbolize_keys
    else
      learner = Bootcamper.find_by_email(email)
      learner_cycle_center =
        learner.learner_programs.last.cycle_center.cycle_center_details

      learner_location = {
        city: learner_cycle_center[:center],
        country: learner_cycle_center[:country]
      }
      learner_details = prep_learner_details(learner, learner_location)
      RedisService.set("learner_profile_#{email}_details", learner_details)
    end
    learner_details
  end

  def prep_learner_details(learner, learner_location)
    {
      name: actual_or_default(learner.name),
      first_name: actual_or_default(learner.first_name),
      last_name: actual_or_default(learner.last_name),
      middle_name: actual_or_default(learner.middle_name),
      username: actual_or_default(learner.username),
      avatar: get_learner_image,
      email: learner.email,
      about: actual_or_default(learner.about),
      gender: actual_or_default(learner.gender),
      phone_number: actual_or_default(learner.phone_number),
      location: learner_location,
      links: {
        github: actual_or_default(learner.github),
        linkedin: actual_or_default(learner.linkedin),
        trello: actual_or_default(learner.trello),
        website: actual_or_default(learner.website)
      }
    }
  end

  def technical_details_params
    params.require(:details).permit(preferred_languages_stacks: [])
  end

  def get_technical_details_params
    if params[:details] && params[:details][:preferred_languages_stacks]
      technical_details_params[:preferred_languages_stacks].map(&:to_i)
    else
      []
    end
  end

  def actual_or_default(value)
    if value.is_a?(String) && value.strip != ""
      value.strip
    else
      "-"
    end
  end
end
