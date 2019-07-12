module ProgressReport
  extend ActiveSupport::Concern

  include SubmissionsControllerHelper

  private

  def set_camper_progress(learner_program_id)
    program_id = LearnerProgram.find(learner_program_id).program_id
    total_assessments = total_assessments(program_id)

    LearnerProgram.update_campers_progress(
      learner_program_id: learner_program_id,
      score: Score.total_assessed(learner_program_id),
      total: total_assessments
    )
  end

  def completed_assessments_per_program(learner_program_id)
    program_id = LearnerProgram.find(learner_program_id).program_id

    total_assessments = total_assessments(program_id)
    total_submittable_assessments = get_total_submittable_assessment(program_id)
    total_learner_assessments = get_required_submissions_total(program_id)

    {
      submittable_assessment: total_submittable_assessments,
      assessed: Score.total_assessed(learner_program_id),
      learner_total_assessments: total_learner_assessments,
      total: total_assessments
    }
  end

  def total_assessments(program_id)
    total_assessments = 0
    phases = Program.find(program_id).phases

    phases.each do |phase|
      total_assessments += phase.assessments.size
    end

    total_assessments
  end

  def get_total_submittable_assessment(program_id)
    Program.get_submittable_assessments(program_id).size
  end

  def get_learner_progress(learner_program_id)
    total_links = OutputSubmission.total_links_submitted(learner_program_id)
    progress = completed_assessments_per_program(
      learner_program_id
    )
    learner = Bootcamper.learner_details(learner_program_id)
    decision = current_decision(learner)
    decision_statuses = DecisionStatus.get_all_statuses - [decision.values]
    learner_programs = LearnerProgram.get_learner_programs(learner.camper_id)
    holistic_evaluation_state = holistic_evaluation_state(learner_program_id)
    {
      assessment_submitted: total_links,
      total_assessments: progress,
      learner: learner,
      decision_statuses: decision_statuses,
      decision: decision,
      learner_programs: learner_programs,
      holistic_evaluations_received: holistic_evaluation_state[:received],
      max_holisitic_evaluations: holistic_evaluation_state[:maximum]
    }
  end

  def current_decision(learner_details)
    decision = {}
    if learner_details.decision_two.blank? ||
       learner_details.decision_two == "Not Applicable"
      decision["Decision 1"] = learner_details.decision_one
    else
      decision["Decision 2"] = learner_details.decision_two
    end

    decision
  end

  def holistic_evaluation_state(learner_program_id)
    learner_program = LearnerProgram.find_by(id: learner_program_id)

    if learner_program.nil?
      {
        received: 0,
        maximum: 0
      }
    else
      {
        received: learner_program.holistic_evaluations_received,
        maximum: learner_program.max_holistic_evaluations
      }
    end
  end
end
