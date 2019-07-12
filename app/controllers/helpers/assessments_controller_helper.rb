module AssessmentsControllerHelper
  include LearnersProfileConcern
  def get_phase_assessments
    phase = Assessment.get_assessments_by_phase(params[:phase_id])
    if phase.nil?
      record_not_found
    else
      render json: group_assessments_by_framework(phase.assessments)
    end
  end

  def get_framework_criteria
    if params[:program_id]
      assessment_details = RedisService.get("
      curricula_page:assessment_details_#{params}")
      unless assessment_details
        assessment_details = assessments_details(params[:program_id])
        RedisService.set("
        curricula_page:assessment_details_#{params}",
                         assessment_details)
        return assessment_details
      end
      render json: assessment_details
    else
      all_assessments = RedisService.get("curricula_page:all_assessments")
      unless all_assessments
        all_assessments = all_assessments_details
        RedisService.set("curricula_page:all_assessment", all_assessments)
        return all_assessments
      end
      render json: all_assessments
    end
  end

  def get_criteria_framework(criteria)
    criteria_framework = []
    criteria.each do |criterium|
      criteria_framework.
        push(framework: criterium.frameworks[0].name, criteria: criterium.name)
    end

    criteria_framework
  end

  def verify_submission_file(file)
    !(file == "null" || file.nil?)
  end

  def validate_learner_file(submission_file)
    return nil unless submission_file.respond_to?(:original_filename)

    extension = check_and_get_extension(
      submission_file.original_filename,
      %w(.png .jpg .jpeg)
    )
    return nil if extension.nil?

    true
  end

  def get_learner_uploaded_file(submission_file, file_name)
    file_validate = validate_learner_file(submission_file)
    if !file_validate
      submission_file
    else
      buffer = submission_file.tempfile
      bucket = GcpService::LEARNER_SUBMISSIONS_BUCKET
      GcpService.upload(file_name, buffer, bucket)
    end
  end

  def update_uploaded_file(output_id, submission_file, file_name)
    file_validate = validate_learner_file(submission_file)
    if !file_validate
      submission_file
    else
      output = OutputSubmission.find(output_id)
      bucket = GcpService::LEARNER_SUBMISSIONS_BUCKET
      buffer = submission_file.tempfile
      link = GcpService.upload(file_name, buffer, bucket)
      GcpService.delete(bucket, output.file_link) if link
      link
    end
  end

  def submission_has_been_provided(phase_id, assessment_id, submission_phase_id)
    OutputSubmission.does_submission_exist?(
      @learner_program.id,
      phase_id,
      assessment_id,
      submission_phase_id
    )
  end

  def get_learner_program
    learner = Bootcamper.find_by(email: session[:current_user_info][:email])
    LearnerProgram.where(camper_id: learner.camper_id).last
  end

  def get_lfa
    learner = Bootcamper.find_by(email: session[:current_user_info][:email])
    learner_program = learner.learner_programs.last
    week1_lfa = Facilitator.find(learner_program.week_one_facilitator_id)
    week2_lfa = Facilitator.find(learner_program.week_two_facilitator_id)
    lfa = week2_lfa.email == "unassigned@andela.com" ? week1_lfa : week2_lfa
    lfa
  end

  def add_learner_output(file_link, file_name, params)
    OutputSubmission.create(
      learner_programs_id: @learner_program.id,
      file_link: file_link,
      file_name: file_name,
      phase_id: params["phase_id"],
      assessment_id: params["assessment_id"],
      link: params["link"],
      description: params["description"],
      submission_phase_id: params["submission_phase_id"]
    )
  end

  def update_learner_output(file_link, file_name, params)
    output = OutputSubmission.find(params["output_id"])
    OutputSubmission.update(
      params["output_id"],
      learner_programs_id: @learner_program.id,
      file_link: file_link || output.file_link,
      file_name: file_name || output.file_name,
      link: params["link"],
      description: params["description"]
    )
  end

  def get_output_submission_response
    response = { saved: true }
    if @output.errors.empty?
      camper_id = LearnerProgram.find(@output.learner_programs_id).camper_id
      response[:assessment_id] = @output.assessment_id
      response[:phase_id] = @output.phase_id
      response[:lfa] = get_lfa.email
      response[:output_name] = Assessment.find(@output.assessment_id).name
      response[:learner_programs_id] = @output.learner_programs_id
      response[:learner_name] = Bootcamper.find(camper_id).name
      response[:phase_name] = Phase.find(@output.phase_id).name
    else
      response[:saved] = false
      response[:errors] = @output.errors.messages
    end
    response
  end

  def populate_submission_types
    submission_types = assessment_params[:submission_types]
    return unless submission_types && !submission_types.is_a?(String)

    submission_stages = prepare_submission_stages(submission_types)
    submission_phases = []
    submission_stages.each do |key, value|
      value.each do |item|
        new_submission_phase = {
          assessment_id: @unique_assessment.id,
          title: item[0],
          day: key.to_i,
          position: item[2].to_i,
          file_type: item[1],
          phase_id: item[3]
        }
        submission_phases << new_submission_phase
      end
    end
    AssessmentOutputSubmission.create(submission_phases)
    assessment_params[:submission_types] = nil
  end

  def prepare_submission_stages(assessment_stages)
    assessment_stages.each do |key, value|
      assessment_stages[key.to_s] = value.map { |_, v| v }
    end
    assessment_stages
  end

  def present_phases
    unless @unique_assessment || !@unique_assessment.submission_phases.empty?
      return {}
    end

    modifying_block = lambda do |key, entries, sub_phases|
      submission_entries = entries.sort_by(&:position)
      sub_phases[key.to_s] = submission_entries
      sub_phases
    end
    build_entry(&modifying_block)
    @submissions_per_day
  end

  def build_entry
    submission_phases = @unique_assessment.submission_phases.
                        where(phase_id: params[:phaseId]).
                        order("created_at desc")
    submission_days = submission_phases.pluck(:day).uniq
    @submissions_per_day = {}
    submission_days.each do |day|
      entries = submission_phases.select { |sub_phase| sub_phase.day == day }
      @submissions_per_day = yield(day, entries, @submissions_per_day)
    end
  end

  def update_and_delete_submission_phases
    @submission_updates = update_params[:phases_to_be_updated]
    @delete_params = update_params[:phases_to_be_deleted]
    if @submission_updates && !@submission_updates.empty?
      update_submission_phases
    end
    delete_submission_phases if @delete_params && !@delete_params.empty?
  end

  def update_submission_phases
    phases = update_params[:phases_to_be_updated]
    sub_phases = phases.is_a?(Array) ? phases : phases.values
    sub_phases.each do |sub_phase|
      query = { assessment_id: sub_phase[:assessment_id],
                phase_id: sub_phase[:phase_id],
                day: sub_phase[:day] }
      AssessmentOutputSubmission.
        where(query).
        update_all(file_type: sub_phase[:file_type])
    end
  end

  def delete_submission_phases
    AssessmentOutputSubmission.where(id: @delete_params).delete_all
  end

  private

  def update_params
    # Doing this because sometimes the client could send
    # nil values, this would coerce it so that the attributes
    # type is compliant
    params[:assessment][:phases_to_be_deleted] ||= []
    params[:assessment][:phases_to_be_updated] ||= []
    params.require(:assessment).
      permit(phases_to_be_deleted: [],
             phases_to_be_updated: %i(assessment_id phase_id day file_type))
  end

  def pagination_query
    return {} unless params[:paginate]

    {
      offset: params[:offset].to_i,
      limit: params[:limit].to_i,
      count: params[:return_count] == "true"
    }
  end
end
