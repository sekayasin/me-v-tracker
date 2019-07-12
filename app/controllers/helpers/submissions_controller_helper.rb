module SubmissionsControllerHelper
  def get_required_submissions_total(program_id)
    phases = Program.find(program_id).phases
    Assessment.get_required_submissions_count(phases)
  end

  def unreviewed_output?(feedback, learner_submissions)
    return false unless learner_submissions.positive?

    feedback.empty? || feedback.size < learner_submissions
  end

  def get_learner_submissions_data(learner_programs)
    total_submission = 0

    unless learner_programs.empty?
      id = learner_programs.first.program_id
      total_submission = get_required_submissions_total(id)
    end

    submissions = Array.new
    learner_programs.each do |learner_program|
      learner_submissions = learner_program.output_submissions.count
      feedback = learner_program.feedback
      data = {
        learner_name: learner_program.bootcamper.name,
        submissions: learner_submissions,
        image: learner_program.bootcamper.avatar,
        total_submission: total_submission,
        learner_program_id: learner_program.id,
        has_unreviewed_output: unreviewed_output?(feedback, learner_submissions)
      }
      submissions.push(data)
    end
    submissions
  end

  def lfa_week_one_query(filters, query_params)
    unless filters[:lfas_week_one].blank?
      query_params[:query_where].push("week_one_facilitator_id IN (?)")
      query_params[:query_where_placeholders].push(filters[:lfas_week_one])
    end
  end

  def lfa_week_two_query(filters, query_params)
    unless filters[:lfas_week_two].blank?
      query_params[:query_where].push("week_two_facilitator_id IN (?)")
      query_params[:query_where_placeholders].push(filters[:lfas_week_two])
    end
  end

  def location_query(filters, query_params)
    unless filters[:locations].blank?
      query_params[:query_where_placeholders].push(filters[:locations])
      query_params[:query_where].push("centers.name IN (?)")
      query_params[:query_includes].push(cycle_center: :center)
      query_params[:query_references].push(:center)
    end
  end

  def cycles_query(filters, query_params)
    unless filters[:cycles].blank?
      query_params[:query_includes].push(cycle_center: :cycle)
      query_params[:query_references].push(:cycle)
      query_params[:query_where].push("cycles.cycle_id IN (?)")
      query_params[:query_where_placeholders].push(filters[:cycles])
    end
  end

  def build_learner_program_query(filters)
    query_params = {
      query_includes: %i(bootcamper output_submissions feedback),
      query_references: [],
      query_where: [],
      query_where_placeholders: []
    }
    lfa_week_one_query(filters, query_params)
    lfa_week_two_query(filters, query_params)
    cycles_query(filters, query_params)
    location_query(filters, query_params)
    query_params
  end

  def lfa_authorized?(lfa_email, learner_program)
    start_date = learner_program.cycle_center.start_date
    end_date = learner_program.cycle_center.end_date
    return false if start_date.nil? || end_date.nil?

    week_one_lfa_email = learner_program.week_one_facilitator.email
    week_two_lfa_email = learner_program.week_two_facilitator.email

    (lfa_email == week_one_lfa_email) || (lfa_email == week_two_lfa_email)
  end
end
