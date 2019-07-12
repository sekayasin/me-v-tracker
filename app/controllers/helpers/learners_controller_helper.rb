module LearnersControllerHelper
  private

  include LearnersProfileConcern
  include GcpService

  def update_learner(learner, data)
    update_learner_center(
      learner,
      data[:learner_info][:city],
      data[:learner_info][:country]
    )
    learner.bootcamper.update(
      email: data[:learner_info][:email],
      gender: data[:learner_info][:gender]
    )
  end

  def update_learner_center(learner, center, country)
    learner_cycle_center = learner.cycle_center
    center = Center.find_by(name: center, country: country)
    if center && learner_cycle_center && learner_cycle_center.center
      learner_cycle_center.center = center
      learner_cycle_center.save
    end
  end

  def get_updated_learner(learner)
    {
      learner: learner.bootcamper,
      country: learner.cycle_center.cycle_center_details[:country],
      city: learner.cycle_center.cycle_center_details[:center]
    }
  end

  def get_learner_image
    learner_email = session[:current_user_info][:email]
    bootcamper = Bootcamper.find_by(email: learner_email)
    if bootcamper && bootcamper[:avatar].is_a?(String)
      bootcamper[:avatar]
    else
      session[:current_user_info][:picture]
    end
  end

  def validate_username_field(params)
    errors = []
    name_field = "username"
    value = exact_value(params[name_field])
    if !value.nil? && /\A[a-zA-Z0-9]{5,30}\z/.match(value).nil?
      errors << name_field
    end
    errors
  end

  def validate_link_fields(params)
    errors = []
    %w(github linkedin).each do |field|
      link = exact_value(params[field])
      errors << field if
        !link.nil? &&
        !link_hosts[field.to_sym].include?(extract_link_host(link))
    end

    website = exact_value(params["website"])
    if !website.nil? && /\A[^(\.)]+\.[^(\.)]+.*\z/.match(website).nil?
      errors << "website"
    end

    trello = exact_value(params["trello"])
    if !trello.nil? && /\A[a-zA-Z0-9]+\z/.match(trello).nil?
      errors << "trello"
    end
    errors
  end

  def extract_personal_details(params)
    fields = %w(
      phone_number
      about
      github
      linkedin
      trello
      website
      username
    )

    personal_details = {}
    fields.each do |field|
      personal_details[field] = params[field]
    end
    personal_details
  end

  def check_telephone(phone_number)
    telephone_number_check = false
    %w(Nigeria Kenya Uganda).each do |country|
      if validate_phone_number(phone_number, country)
        telephone_number_check = true
        break
      end
    end
    telephone_number_check
  end

  def validate_personal_details(params)
    errors = validate_username_field(params)
    errors += validate_link_fields(params)
    errors << "phone_number" unless check_telephone(params["phone_number"])
    errors
  end

  def validate_learner_image(image_file)
    return nil unless image_file.respond_to?(:original_filename)

    extension = check_and_get_extension(
      image_file.original_filename,
      %w(.png .jpg .jpeg)
    )
    return ["image-extension"] if extension.nil?

    true
  end

  def learner_image_filename
    camper_id = get_learner[:camper_id]
    "IMG#{camper_id}.jpg"
  end

  def upload_image_to_gcp(filename, buffer)
    bucket = GcpService::PROFILE_PICTURES_BUCKET
    GcpService.upload(filename, buffer, bucket)
  end

  def upload_learner_image(image_file)
    image_validate = validate_learner_image(image_file)
    if !image_validate.is_a?(Array) && !image_validate.nil?
      buffer = image_to_thumbnail_buffer(image_file)
      filename = learner_image_filename
      upload_image_to_gcp(filename, buffer)
    else
      image_validate
    end
  end

  def finalize_personal_details_update(params)
    personal_details = extract_personal_details(params)
    image_url = upload_learner_image(params[:image])
    if image_url.is_a?(Array)
      return { status: false, errors: image_url }
    end

    unless image_url.nil?
      personal_details["avatar"] = image_url
    end

    save_personal_details(personal_details)
    { status: true, personal_details: personal_details }
  end

  def save_personal_details(personal_details)
    camper_id = get_learner[:camper_id]
    bootcamper = Bootcamper.find_by(camper_id: camper_id)
    bootcamper_details = personal_details
    avatar = bootcamper_details["avatar"]
    bootcamper_details["avatar"] = bootcamper[:avatar] if avatar.nil?
    bootcamper.update(bootcamper_details)
  end

  def get_alc_language_stacks(camper_id)
    alc_stack = RedisService.
                get("learner_profile_#{camper_id}_alc_stacks")
    unless alc_stack
      alc_stack = LearnerProgram.get_learner_alc_languages_stacks(camper_id)
      RedisService.
        set("learner_profile_#{camper_id}_alc_stacks", alc_stack)
    end
    alc_stack
  end

  def get_preferred_language_stacks(camper_id)
    Bootcamper.get_preferred_languages_stacks(camper_id)
  end

  def get_learner_latest_learner_program(query = [])
    learner = Bootcamper.find_by(email: session[:current_user_info][:email])
    LearnerProgram.get_latest_learner_program(learner.camper_id, query)
  end

  def gather_phase_assessments(phase, learner_program_id)
    phase.assessments.map do |phase_assessment|
      {
        id: phase_assessment.id,
        name: phase_assessment.name,
        description: phase_assessment.description,
        output: phase_assessment.expectation,
        requires_submission: phase_assessment.requires_submission,
        submitted: OutputSubmission.does_submission_exist?(
          learner_program_id,
          phase.id,
          phase_assessment.id
        ),
        feedback: Feedback.find_learner_feedbacks(
          learner_program_id: learner_program_id,
          phase_id: phase.id,
          assessment_id: phase_assessment.id
        ),
        framework_id: phase_assessment.framework.id,
        submission_types: phase_assessment.submission_types
      }
    end
  end

  def generate_phase_assessments(program, learner_program)
    start_date = learner_program.cycle_center.start_date
    offset = 0
    program.phases.map do |phase|
      phase = Assessment.get_assessments_by_phase(phase.id)
      assessments = gather_phase_assessments(phase, learner_program.id)
      phase = phase.attributes
      phase["due_date"] = Phase.get_due_date(phase, start_date, offset)
      offset += phase["phase_duration"] unless phase["phase_duration"].nil?
      {
        id: phase["id"],
        name: phase["name"],
        due_date: phase["due_date"],
        assessments: assessments
      }
    end
  end
end
