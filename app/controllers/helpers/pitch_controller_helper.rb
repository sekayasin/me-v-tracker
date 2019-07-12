module PitchControllerHelper
  def pitch_params(params)
    {
      pitch: {
        cycle_center_id: params["cycle_center_id"],
        demo_date: params["demo_date"],
        created_by: session[:current_user_info][:email]
      },
      panelist: {
        email: params["lfa_email"]
      },
      learner_pitch: {
        camper_id: params["camper_id"]
      },
      pitch_id: params["pitch_id"],
      program_id: params["program_id"],
      updates: params["updates"],
      center_name: params["center_name"],
      cycle_number: params["cycle_number"]
    }
  end

  def invite_pitch_panelist(lfa_email, pitch)
    pitch_cycle =
      CycleCenter.where(cycle_center_id: params[:cycle_center_id]).
      includes(%i(center cycle)).
      pluck(:'centers.name', :'cycles.cycle', :program_id).
      map do |name, cycle, program_id|
        { name: name, cycle: cycle, program_id: program_id }
      end

    pitch_link = set_invite_link(pitch.id, pitch_cycle[0][:program_id])
    send_invitation_mail(lfa_email[:email], pitch_link, pitch, pitch_cycle)
  end

  def learner_ratings_params(params, panelist_id)
    {
      ui_ux: params[:uiUx].to_i,
      api_functionality: params[:apiFunctionality].to_i,
      error_handling: params[:errorHandling].to_i,
      project_understanding: params[:projectUnderstanding].to_i,
      presentational_skill: params[:presentationalSkill].to_i,
      decision: params[:decision],
      comment: params[:comment],
      learners_pitch_id: params[:learnerId].to_i,
      panelist_id: panelist_id
    }
  end

  def build_pitch(pitch_data)
    Pitch.create!(pitch_data.compact)
  rescue ActiveRecord::RecordInvalid => e
    render json: e.message, status: 400
  end

  def prepare_panelists(pitch_data, pitch_id)
    panelists = pitch_data[:email]
    all_panelists = panelists.map do |panelist|
      {
        pitch_id: pitch_id,
        email: panelist,
        accepted: "False"
      }
    end
    Panelist.create!(all_panelists)
  rescue ActiveRecord::RecordInvalid => e
    render json: e.message, status: 400
  end

  def prepare_learners(learner_data, pitch_id)
    learners = learner_data[:camper_id]
    all_learners = learners.map do |learner|
      {
        pitch_id: pitch_id,
        camper_id: learner
      }
    end
    LearnersPitch.create!(all_learners)
  rescue ActiveRecord::RecordInvalid => e
    render json: e.message, status: 400
  end

  def fetch_pitches(is_admin, is_panelist)
    if is_admin
      @pitches = Pitch.joins(:panelists).
                 where("created_by = ? OR panelists.email = ?",
                       @user_email, @user_email).
                 order("demo_date DESC")
    elsif is_panelist
      @pitches = Pitch.joins(:panelists).
                 where("demo_date >= ? AND panelists.email = ?",
                       Time.now.to_date, @user_email).
                 order("created_at DESC")
    end
    pitches_center =
      @pitches.map do |pitch|
        CycleCenter.where(cycle_center_id: pitch[:cycle_center_id]).
          includes(%i(center cycle)).
          order("cycles_centers.created_at DESC").
          pluck(:cycle_center_id, :'centers.name', :'cycles.cycle').
          map do |cycle_center_id, name, cycle|
          {
            pitch_id: pitch[:id],
            demo_date: pitch[:demo_date],
            cycle_center_id: cycle_center_id,
            name: name,
            cycle: cycle,
            learners_count: LearnersPitch.where(pitch_id: pitch[:id]).length,
            created: pitch[:created_at],
            overdue: check_overdue_pitch(pitch[:demo_date])
          }
        end.first
      end
    prepare_pitches(pitches_center) if is_admin || is_panelist
  end

  def fetch_pitch_learners(pitch_id, panelist_email)
    panelist_id = Panelist.find_by(email: panelist_email).id
    learners_details = LearnersPitch.where(pitch_id: pitch_id).
                       includes(%i(bootcamper pitch)).
                       order("bootcampers.first_name").
                       pluck(:id, :pitch_id,
                             :'bootcampers.first_name',
                             :'bootcampers.last_name',
                             :'bootcampers.email',
                             :'pitches.demo_date',
                             :created_at).
                       map do |details|
      rated = Rating.where(
        learners_pitch_id: details[0],
        panelist_id: panelist_id
      ).any?
      { 'id': details[0],
        'pitch_id': details[1],
        'is_graded': rated,
        'first_name': details[2],
        'last_name': details[3],
        'email': details[4],
        'demo_date': details[5],
        'created_at': details[6] }
    end
    prepare_pitches(learners_details)
  end

  def prepare_pitches(data)
    page = params[:page].nil? ? 1 : params[:page]
    size = params[:size].nil? ? 10 : params[:size]
    paginated_data = Kaminari.paginate_array(data).
                     page(page).
                     per(size)
    data = paginated_data
    { admin: helpers.admin?,
      panelist: helpers.pitch_panelist?,
      paginated_data: data,
      total_pages: data.total_pages,
      current_page: data.current_page,
      data_count: data.total_count }
  end

  def check_overdue_pitch(date)
    date < Date.today
  end

  def fetch_learner_ratings
    @learner_details = LearnersPitch.where(id: params[:learners_pitch_id]).
                       includes(%i(bootcamper)).
                       pluck(:'bootcampers.first_name',
                             :'bootcampers.last_name',
                             :'bootcampers.email').
                       map do |learner|
      { first_name: learner[0],
        last_name: learner[1],
        email: learner[2] }
    end.first

    @rating_details = {
      ratings: prepare_learner_ratings(params[:learners_pitch_id]),
      learner: @learner_details
    }

    if helpers.pitch_panelist?
      @rating_details[:panelist_email] = @user_email
    end

    @rating_details
  end

  def fetch_learners_average_ratings
    @average_ratings = AverageRatings.where(pitch_id: params[:pitch_id])
    @average_ratings = @average_ratings.
                       each_with_object([]) { |item, array| array << item }
    prepare_pitches(@average_ratings)
  end

  def prepare_learner_ratings(learners_pitch_id)
    @learner_ratings = Rating.where(learners_pitch_id: learners_pitch_id).
                       pluck(:learners_pitch_id, :panelist_id, :ui_ux,
                             :api_functionality, :error_handling,
                             :project_understanding, :presentational_skill,
                             :comment, :decision).
                       map do |rating|
      panelist_email = Panelist.find_by(id: rating[1]).email
      { learners_pitch_id: rating[0],
        panelist_id: rating[1],
        ui_ux: rating[2],
        api_functionality: rating[3],
        error_handling: rating[4],
        project_understanding: rating[5],
        presentational_skill: rating[6],
        comment: rating[7],
        decision: rating[8],
        panelist_email: panelist_email }
    end
  end

  def get_learner_pitch_details
    LearnersPitch.where(id: params[:learner_id]).
      includes(%i(bootcamper pitch)).pluck(
        :'bootcampers.first_name',
        :'bootcampers.last_name',
        :'pitches.demo_date'
      ).flatten(1)
  end

  def get_campers_email(campers_detail)
    campers_detail.map do |camper_id|
      Bootcamper.find(camper_id).email
    end
  end

  def send_invitation_mail(emails_list, pitch_link, pitch, pitch_cycle)
    emails_list.each do |email|
      PitchInvitationMailer.
        invite_panelist_to_a_pitch(
          email, pitch_link, pitch, pitch_cycle
        ).deliver_now
    end
  end

  def send_reschedule_mail(emails_list, pitch_data)
    emails_list.each do |email|
      PitchInvitationMailer.
        notify_rescheduled_pitch(
          email,
          pitch_data[:pitch][:demo_date],
          pitch_data[:center_name],
          pitch_data[:cycle_number]
        ).deliver_now
    end
  end

  def set_invite_link(pitch_id, pitch_cycle_program)
    base_path = "#{request.protocol}#{request.host_with_port}"
    href = "/pitch/#{pitch_id}?programId=#{pitch_cycle_program}"
    base_path + href
  end

  def get_pitch_cycle_center(pitch_id)
    CycleCenter.joins(:pitch).
      where("pitches.id = ?", pitch_id).
      pluck(:cycle_center_id, :program_id, :center_id, :cycle_id).
      first
  end

  def update_cycle_center_program(pitch_data)
    if pitch_data[:updates][:program] == "true"
      CycleCenter.find(pitch_data[:pitch][:cycle_center_id]).
        update(program_id: pitch_data[:program_id])
    end
  end

  def update_pitch_cycle_center(pitch_data)
    if pitch_data[:updates][:cycle_center] == "true"
      Pitch.find(pitch_data[:pitch_id]).
        update(cycle_center_id: pitch_data[:pitch][:cycle_center_id])
      LearnersPitch.where(pitch_id: pitch_data[:pitch_id]).delete_all
      prepare_learners(pitch_data[:learner_pitch], pitch_data[:pitch_id])
    end
  end

  def update_pitch_date(pitch_data)
    if pitch_data[:updates][:demo_date] == "true"
      Pitch.find(pitch_data[:pitch_id]).
        update(demo_date: pitch_data[:pitch][:demo_date])
      panelists = Panelist.where(pitch_id: pitch_data[:pitch_id]).pluck(:email)
      mail_list = get_campers_email(pitch_data[:learner_pitch][:camper_id])
      mail_list.concat(panelists)
      send_reschedule_mail(mail_list, pitch_data)
    end
  end

  def add_panelists_to_pitch(pitch_data)
    unless pitch_data[:updates][:added_panelists].blank?
      lfa_emails = { email: pitch_data[:updates][:added_panelists] }
      prepare_panelists(lfa_emails, pitch_data[:pitch_id])
      link = set_invite_link(pitch_data[:pitch_id], pitch_data[:program_id])
      pitch = Pitch.find(pitch_data[:pitch_id])
      pitch_cycle = [{
        name: pitch_data[:center_name], cycle: pitch_data[:cycle_number]
      }]
      send_invitation_mail(lfa_emails[:email], link, pitch, pitch_cycle)
    end
  end

  def remove_panelists_from_pitch(pitch_data)
    unless pitch_data[:updates][:removed_panelists].blank?
      pitch_data[:updates][:removed_panelists].each do |email|
        lfas = Panelist.find_by(email: email, pitch_id: pitch_data[:pitch_id])
        lfas.destroy if lfas.present?
      end
    end
  end

  def send_mail(panelist)
    unless panelist[:accepted] == "True"
      Panelist.where(
        email: panelist[:email], pitch_id: panelist[:pitch_id]
      ).update(accepted: "True")
      send_response
    end
  end
end
