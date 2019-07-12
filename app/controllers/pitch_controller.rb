class PitchController < ApplicationController
  before_action :get_current_user_email,
                except: %i(create
                           get_learners_cycle
                           get_program_cycle
                           edit
                           update)
  include PitchControllerHelper
  include BootcampersHelper

  def index
    unless helpers.admin? || helpers.pitch_panelist?
      return redirect_to index_path
    end

    @pitches_data = fetch_pitches(helpers.admin?, helpers.pitch_panelist?)
    respond_to do |format|
      format.json { render json: @pitches_data }
      format.html { render template: "pitch/index" }
    end
  end

  def show
    if helpers.admin?
      admin_view_panelist_learners
      @avg_ratings = fetch_learners_average_ratings
      accept_pitch_invite if !!helpers.fetch_pitch_panellist
      respond_to do |format|
        format.json do
          render json: {
            campers_details: @campers_details,
            avg_ratings: @avg_ratings
          }, status: 200
        end
        format.html { render template: "pitch/show" }
      end
    else
      accept_pitch_invite
    end
  end

  def admin_view_panelist_learners
    fetch_center_details
    @panelist = Panelist.where("pitch_id = ?", params[:pitch_id]).
                pluck(:email, :accepted, :created_at)
    learner_details = LearnersPitch.where(pitch_id: params[:pitch_id]).
                      includes(%i(bootcamper)).order("id").
                      pluck(:id, :pitch_id, :'bootcampers.first_name',
                            :'bootcampers.last_name', :'bootcampers.email',
                            :created_at).
                      map do |details|
      graded = Rating.where(learners_pitch_id: details[0]).any?
      { 'id': details[0], 'pitch_id': details[1],
        'first_name': details[2], 'last_name': details[3],
        'email': details[4], 'created_at': details[5], 'is_graded': graded }
    end
    @campers_details = prepare_pitches(learner_details)
    if @panelist.empty?
      return redirect_to not_found_path
    end
  rescue ActiveRecord::RecordNotFound, ActiveRecord::StatementInvalid => e
    Bugsnag.custom_notify(e)
    redirect_to not_found_path
  end

  def destroy
    if helpers.admin?
      rated_learners = LearnersPitch.joins(:ratings).find_by(
        pitch_id: params[:pitch_id]
      ).present?
      if rated_learners
        render json: {
          error: "You cannot delete a pitch with rated learners",
          status: 400
        }
      else
        pitch = Pitch.find_by(id: params[:pitch_id])
        pitch.destroy
        render json: { message: "Pitch successfully deleted", status: 200 }
      end
    else
      redirect_to index_path
    end
  rescue ActiveRecord::RecordNotFound => e
    Bugsnag.custom_notify(e)
    render json: { error: "Sorry, the pitch does not exist", status: 404 }
  rescue StandardError => e
    Bugsnag.custom_notify(e)
    render json: { error: "An error occurred", status: 400 }
  end

  def show_learner_ratings
    @rating_details = fetch_learner_ratings
    render json: { rating_details: @rating_details, status: 200 }
  end

  def pitch_setup
    redirect_non_admin
  end

  def create
    pitch_data = pitch_params(params)
    pitch = build_pitch(pitch_data[:pitch])
    prepare_panelists(pitch_data[:panelist], pitch.id)
    prepare_learners(pitch_data[:learner_pitch], pitch.id)
    invite_pitch_panelist(pitch_data[:panelist], pitch)
  rescue StandardError => e
    pitch.destroy
    Bugsnag.custom_notify(e)
    render json: { message: "An error occurred", status: 400 }
  else
    render json: { message: "Pitch successfully created", status: 201 }
  end

  def get_rating_breakdown
    render template: "pitch/pitch_rating_breakdown"
  end

  def rate_learners
    panelist_id = Panelist.find_by(email: @user_email).id
    panellist = helpers.fetch_pitch_panellist
    @panellist_visit_status = panellist.visited?
    learner = LearnersPitch.find_by(pitch_id: params[:pitch_id],
                                    id: params[:learner_id])
    if learner.blank?
      return redirect_to not_found_path
    end

    learner_pitch_details = get_learner_pitch_details
    demo_date = learner_pitch_details[2]
    if demo_date != Date.today
      flash[:success] = "You can only rate a learner during the demo"
      return redirect_to action: :show
    end
    rated = Rating.find_by(
      learners_pitch_id: params[:learner_id], panelist_id: panelist_id
    )
    if rated
      flash[:error] = "This learner has already been Rated"
      return redirect_to action: :show
    end
    panellist.update_attribute(:visited, true)
    @first_name = learner_pitch_details[0]
    @last_name = learner_pitch_details[1]
  end

  def edit
    is_rated = get_pitch_ratings(params[:pitch_id])
    demo_date = Pitch.find(params[:pitch_id]).demo_date

    if Date.today > demo_date || is_rated.present?
      flash[:success] = "Rated or Overdue Pitch cannot be edited"
      return redirect_to action: :index
    end

    cycle_center = get_pitch_cycle_center(params[:pitch_id])
    program_name = Program.find(cycle_center[1]).name
    center_name = Center.find(cycle_center[2]).name
    cycle_number = Cycle.find(cycle_center[3]).cycle
    panelists = Panelist.where("pitch_id = ?", params[:pitch_id]).pluck(:email)
    pitch_details = {
      cycle_center_id: cycle_center[0],
      cycle_number: cycle_number,
      center_name: center_name,
      program_id: cycle_center[1],
      program_name: program_name,
      panelists: panelists,
      demo_date: demo_date
    }

    respond_to do |format|
      format.json { render json: pitch_details }
      format.html { render template: "pitch/pitch_setup" }
    end
  end

  def update
    pitch_data = pitch_params(params)
    update_cycle_center_program(pitch_data)
    update_pitch_cycle_center(pitch_data)
    update_pitch_date(pitch_data)
    add_panelists_to_pitch(pitch_data)
    remove_panelists_from_pitch(pitch_data)
  rescue StandardError
    render json: { message: "An error occurred", status: 400 }
  else
    render json: { message: "Pitch successfully updated", status: 200 }
  end

  def get_learners_cycle
    bootcampers_ids = LearnerProgram.active.
                      where("cycle_center_id = ?
                        AND decision_one = ?",
                            params[:cycle_center_id], "Advanced").
                      pluck(:camper_id)

    render json: { data: bootcampers_ids, status: 200 }
  end

  def get_program_cycle
    cycle_center_ids =
      LearnerProgram.active.where("program_id = ? AND decision_one = ?",
                                  params[:program_id], "Advanced").
      pluck(:cycle_center_id).uniq

    cycles_centers = cycle_center_ids.map do |cycle_center_id|
      CycleCenter.active.where("cycle_center_id = ?", cycle_center_id).
        includes(%i(center cycle)).
        pluck(:'centers.name', :'cycles.cycle').
        map do |name, cycle|
        { cycle_center_id: cycle_center_id, name: name, cycle: cycle }
      end
    end

    render json: { centers: cycles_centers.flatten, status: 200 }
  end

  def submit_learner_ratings
    panelist_id = Panelist.find_by(email: @user_email).id
    learner_ratings_data = learner_ratings_params(params,
                                                  panelist_id)
    learner_rating = Rating.create!(learner_ratings_data)
  rescue StandardError => e
    learner_rating.destroy
    Bugsnag.custom_notify(e)
    render json: { message: "An error occurred", status: 400 }
  else
    render json: { message: "Learner successfully rated",
                   status: 201,
                   id: params[:pitchId] }
  end

  def accept_pitch_invite
    return display_pitch_learners if andelan?(@user_email)

    redirect_to logout_path
  end

  private

  def get_current_user_email
    @user_email = session[:current_user_info][:email]
  end

  def display_pitch_learners
    panelist = helpers.fetch_pitch_panellist
    return redirect_to not_found_path if panelist.blank?

    @campers_details = fetch_pitch_learners(
      panelist[:pitch_id], panelist[:email]
    )
    send_mail(panelist)
    return if helpers.admin?

    if @campers_details[:paginated_data][0][:demo_date] < Date.today
      redirect_to not_found_path
    else
      respond_to do |format|
        format.json do
          render json: {
            campers_details: @campers_details
          }, status: 200
        end
        format.html { render template: "pitch/show" }
      end
    end
  end

  def send_response
    flash[:success] = "Thank you for accepting the invitation"
  end

  def fetch_center_details
    pitch = Pitch.find_by(id: params[:pitch_id])
    @center_details =
      CycleCenter.where(cycle_center_id: pitch[:cycle_center_id]).
      includes(%i(center cycle)).
      pluck(:'centers.name', :'cycles.cycle').flatten
  end

  def get_pitch_panellist(email)
    panelist = Panelist.find_by(
      email: email, pitch_id: params[:pitch_id]
    )
    return display_pitch_learners(panelist) unless panelist.blank?

    redirect_to not_found_path
  end

  def get_pitch_ratings(pitch_id)
    Rating.joins(:learners_pitch).
      where("learners_pitches.pitch_id = ?", pitch_id)
  end
end
