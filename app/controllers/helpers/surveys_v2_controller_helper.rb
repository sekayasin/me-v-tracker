module SurveysV2ControllerHelper
  include SurveysV2Exceptions
  include BootcamperDataConcern

  def admin_helper
    unless helpers.admin?
      raise SurveyException.new("Invalid access to non-admins")
    end
  end

  def build_survey(survey_data)
    admin_helper
    NewSurvey.create!(survey_data.compact)
  rescue ActiveRecord::RecordNotFound
    raise SurveyException.new("Invalid cycle center recipient ids provided")
  rescue ActiveRecord::RecordInvalid => e
    raise SurveyException.new(e.message)
  end

  def build_questions(survey, survey_data)
    questions = []
    survey_data[:survey_questions].each do |question_data|
      begin
        question = build_question(survey, question_data)
        @question_data_map[question.id] = question_data
        questions << question
      rescue ActiveRecord::RecordInvalid => e
        raise SurveyQuestionException.new(e.message, question_data)
      end
    end
    questions
  end

  def build_options(questions)
    option_questions = questions.select do |question|
      question.questionable.is_a?(SurveyOptionQuestion)
    end
    option_questions.each do |question|
      begin
        build_question_options(question)
      rescue ActiveRecord::RecordInvalid => e
        raise SurveyOptionException.new(e.message, question)
      end
    end
  end

  def build_section_rules(survey, survey_data)
    survey_data[:survey_section_links].each do |section, link_info|
      section_to_link = SurveySection.find_by(
        new_survey_id: survey.id,
        position: section.split(" ")[1]
      )
      option_to_link = survey.survey_sections.find_by(
        position: link_info["section_number"]
      ).survey_questions.find_by(
        position: link_info["question_number"]
      ).questionable.survey_options.find_by(
        position: link_info["option_number"]
      )
      SurveySectionRule.create!(
        survey_section_id: section_to_link.id,
        survey_option_id: option_to_link.id
      )
    end
  end

  def duplicate_survey(id)
    old_survey = NewSurvey.find_by_id!(id)
    old_survey_collaborators = NewSurveyCollaborator.
                               where("new_survey_id = ?", id)
    new_survey = old_survey.dup
    new_survey.title = "Copy of #{new_survey.title}"
    new_survey.status = "draft"
    new_survey.survey_responses_count = 0
    new_survey.save!
    old_survey_collaborators.empty? || old_survey_collaborators.nil?
    collaborators = old_survey.collaborators.map(&:email)
    save_collaborator(collaborators, new_survey)
    [old_survey, new_survey]
  end

  def duplicate_survey_sections(survey, survey_id)
    survey.survey_sections.each do |tmp_section|
      new_section = tmp_section.dup
      new_section.new_survey_id = survey_id
      new_section.save!
      duplicate_survey_questions(tmp_section, new_section.id)
    end
  end

  private

  def duplicate_survey_questions(survey_section, section_id)
    survey_section.survey_questions.each do |question|
      question_object = duplicate_question(question)
      cloned_question = question.dup
      cloned_question.questionable_id = question_object[:id]
      cloned_question.survey_section_id = section_id
      cloned_question.save!
    end
  end

  def duplicate_question(question)
    survey_question = {}
    id = question.questionable_id
    case question.questionable_type
    when "SurveyOptionQuestion"
      tmp_question = SurveyOptionQuestion.find_by_id!(id)
      survey_question = tmp_question.dup
      survey_question.save!
      duplicate_options(tmp_question, survey_question.id)
    when "SurveyDateQuestion"
      survey_question = save_question_stub(SurveyDateQuestion, id)
    when "SurveyTimeQuestion"
      survey_question = save_question_stub(SurveyTimeQuestion, id)
    when "SurveyScaleQuestion"
      survey_question = save_question_stub(SurveyScaleQuestion, id)
    when "SurveyParagraphQuestion"
      survey_question = save_question_stub(SurveyParagraphQuestion, id)
    end
    survey_question
  end

  def save_question_stub(resource, id)
    tmp = resource.find_by_id!(id).dup
    tmp.save!
    tmp
  end

  def duplicate_options(survey_option_question, new_option_question_id)
    survey_option_question.survey_options.each do |option_item|
      option_clone = option_item.dup
      option_clone.survey_option_question_id = new_option_question_id
      option_clone.save!
    end
  end

  def build_question(survey, question_data)
    section = SurveySection.find_or_create_by!(
      new_survey_id: survey.id,
      position: question_data["section"]
    )
    questionable = build_questionable(question_data)
    question = SurveyQuestion.create!(
      questionable: questionable,
      survey_section_id: section.id,
      position: question_data["position"],
      question: question_data["question"],
      is_required: question_data["is_required"],
      description: question_data["description"],
      description_type: question_data["description_type"]
    )
    question.description =
      case question_data["description_type"]
      when "image" then upload_image_description(question)
      when "video" then upload_video_description(question)
      else question.description
      end
    question.save!
    question
  end

  def build_questionable(question_data)
    case question_data["type"]
    when "SurveySelectQuestion", "SurveyCheckboxQuestion",
      "SurveyMultipleChoiceQuestion", "SurveyPictureOptionQuestion",
      "SurveyPictureCheckboxQuestion", "SurveyMultigridOptionQuestion",
      "SurveyMultigridCheckboxQuestion"
      SurveyOptionQuestion.create!(question_type: question_data["type"])
    when "SurveyDateQuestion"
      SurveyDateQuestion.create!(min: question_data["date_limits"]["min"],
                                 max: question_data["date_limits"]["max"])
    when "SurveyTimeQuestion"
      SurveyTimeQuestion.create!(min: question_data["min"],
                                 max: question_data["max"])
    when "SurveyScaleQuestion"
      SurveyScaleQuestion.create!(min: question_data["scale"]["min"],
                                  max: question_data["scale"]["max"])
    when "SurveyParagraphQuestion"
      SurveyParagraphQuestion.create!(max_length: question_data["max_length"])
    else
      raise SurveyQuestionException.new(
        "Invalid question type #{question_data['type']}",
        question_data
      )
    end
  end

  def build_question_options(question)
    options_data = question_options(question)
    if options_data.length < 2
      raise SurveyOptionException.new("Two or more options required", question)
    end

    options_data.each do |option_data|
      option_data["option"] =
        if option_data["option_type"] == "image"
          upload_option_image(option_data["option"])
        else
          option_data["option"]
        end
      SurveyOption.create!(
        option: option_data["option"],
        position: option_data["position"],
        option_type: option_data["option_type"],
        survey_option_question_id: question.questionable.id
      )
    end
  end

  def question_options(question)
    question_data = @question_data_map[question.id]
    case question_data["type"]
    when "SurveySelectQuestion", "SurveyCheckboxQuestion",
      "SurveyMultipleChoiceQuestion"
      question_data["survey_options"].map do |option|
        option["option_type"] = "text"
        option
      end
    when "SurveyPictureOptionQuestion", "SurveyPictureCheckboxQuestion"
      question_data["survey_options"].map do |option|
        option["option_type"] = "image"
        option
      end
    when "SurveyMultigridCheckboxQuestion", "SurveyMultigridOptionQuestion"
      options = []
      question_data["survey_options"]["rows"].each do |option|
        option["option_type"] = "row"
        options << option
      end
      question_data["survey_options"]["columns"].each do |option|
        option["option_type"] = "column"
        options << option
      end
      options
    end
  end

  def upload_video_description(question)
    file = params[question.description.to_s]
    return question.description unless valid_video_file?(file)

    base_name = "video_description_#{question.id}"
    upload_file(file, base_name)
  end

  def upload_image_description(question)
    file = params[question.description.to_s]
    return question.description unless valid_image_file?(file)

    base_name = "image_description_#{question.id}"
    upload_file(file, base_name)
  end

  def upload_option_image(file_key)
    file = params[file_key]
    return file_key unless valid_image_file?(file)

    base_name = "survey_option_image_#{file_key}"
    upload_file(file, base_name)
  end

  def upload_file(file, base_name = generate_id)
    extension = File.extname(file.original_filename).downcase
    file_name = "#{base_name}#{extension}"
    bucket = GcpService::SURVEY_MEDIA_BUCKET
    GcpService.upload(file_name, file.tempfile, bucket)
  end

  def fetch_surveys(is_admin)
    admin_email = session[:current_user_info][:email]
    survey_collaborator = Collaborator.find_by(
      email: admin_email
    )
    get_survey_query = []
    if is_admin && !survey_collaborator.nil?
      get_survey_query = NewSurvey.joins(:new_survey_collaborators).
                         where(
                           "(collaborator_id = ?) AND (survey_creator != ?)",
                           survey_collaborator[:id], admin_email
                         ).order("created_at desc")
    end
    get_survey_query += NewSurvey.
                        where(
                          "survey_creator = ?",
                          admin_email
                        ).order("created_at desc")
    return prepare_surveys(get_survey_query) if is_admin

    cycle_center_id = bootcamper_program(%i(bootcamper cycle_center)).
                      pluck(:cycle_center_id)
    prepare_surveys(NewSurvey.joins(:cycle_centers).published.
    where(cycle_centers_new_surveys: { cycle_center_id: cycle_center_id }).
    order("created_at desc"))
  end

  def prepare_surveys(surveys)
    page = params[:page].nil? ? 1 : params[:page]
    size = params[:size].nil? ? 10 : params[:size]
    paginated_surveys = Kaminari.paginate_array(surveys).
                        page(page).
                        per(size)
    surveys = paginated_surveys
    { admin: helpers.admin?,
      paginated_data: surveys,
      total_pages: surveys.total_pages,
      current_page: surveys.current_page,
      surveys_count: surveys.total_count }
  end

  def valid_image_file?(file)
    return false unless file.respond_to?(:original_filename)

    extension = File.extname(file.original_filename).downcase
    %w(.png .jpg .jpeg).include? extension
  end

  def valid_video_file?(file)
    return false unless file.respond_to?(:original_filename)

    extension = File.extname(file.original_filename).downcase
    %w(.mp4 .mkv .avi .webm .3gp).include? extension
  end

  def validate_cycle_ceter_presence(survey_data)
    if survey_data["recipients"]
      CycleCenter.find(survey_data["recipients"])
    end
  end

  def survey_params(survey_params)
    survey_data = JSON.parse(survey_params)
    cycle_centers = validate_cycle_ceter_presence(survey_data)
    {
      survey: {
        title: survey_data["title"],
        description: survey_data["description"],
        status: survey_data["status"],
        end_date: survey_data["end_date"],
        start_date: survey_data["start_date"],
        survey_responses_count: 0,
        edit_response: survey_data["edit_response"],
        cycle_centers: cycle_centers || nil,
        survey_creator: session[:current_user_info][:email]
      },
      collaborators: survey_data["collaborators"],
      program_id: survey_data["program_id"],
      survey_questions: survey_data["survey_questions"],
      survey_section_links: survey_data["survey_section_links"]
    }
  rescue JSON.parseError
    raise SurveyException.new("Invalid JSON Schema")
  end

  def download_media_object(media_url)
    bucket = GcpService::SURVEY_MEDIA_BUCKET
    image = GcpService.download(bucket, media_url)
    send_data image.body,
              type: image.headers["Content-Type"], disposition: "inline"
  end

  def check_country_timezone(country_name, survey)
    if country_name != "Nigeria"
      survey.start_date.to_datetime - (3 / 24.0)
    else
      survey.start_date.to_datetime - (1 / 24.0)
    end
  end

  def send_notification_per_timezone(cycle_centers, survey)
    cycle_centers.each do |cycle_center|
      country_name = cycle_center.center.name
      start_date = check_country_timezone(country_name, survey)
      SurveyV2NotificationJob.set(wait_until: start_date.to_datetime).
        perform_later(
          survey.id,
          survey.start_date.to_s,
          cycle_center
        )
    end
  end

  def invite_collaborator(collaborators, survey, program_id)
    base_path = "#{request.protocol}#{request.host_with_port}"
    href = "/surveys-v2/#{survey[:id]}/edit?programId=#{program_id}"
    survey_link = base_path + href
    collaborators ||= []
    save_collaborator(collaborators, survey)
    unless collaborators.nil? || collaborators.empty?
      collaborators.each do |collaborator|
        SurveyCollaboratorMailer.
          invite_survey_collaborator(
            collaborator, survey_link, survey
          ).deliver_now
      end
    end
  end

  def save_collaborator(collaborators, survey)
    survey.collaborators = collaborators.map do |collaborator_email|
      Collaborator.find_or_create_by(email: collaborator_email)
    end
  end

  def collaborator
    survey_collaborator = Collaborator.find_by(
      email: session[:current_user_info][:email]
    )
    is_collaborator = false
    unless survey_collaborator.nil?
      can_edit = NewSurvey.joins(:new_survey_collaborators).
                 where(
                   "collaborator_id
                   = ? AND new_survey_id
                   = ? ", survey_collaborator[:id], params[:survey_id]
                 )
      unless can_edit.empty?
        is_collaborator = true
      end
    end
    is_collaborator
  end
end
