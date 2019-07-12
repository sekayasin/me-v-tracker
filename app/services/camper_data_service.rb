require "application_helper"

module CamperDataService
  include ApplicationHelper

  def decide(camper)
    decisions = []
    if camper.decision_one.blank?
      decision_one = set_stubs("", "decision_one")
      decision_two = set_stubs("", "decision_two")
    else
      decision_one = camper.decision_one
      decision_two = camper.decision_two
    end
    week_two_lfa = if camper.week_two_facilitator.blank?
                     set_stubs("", "week_two_lfa")
                   else
                     camper.week_two_facilitator.email
                   end
    decisions.push(decision_one, decision_two, week_two_lfa)
    decisions
  end

  extend self
  def get_camper_data(serial_number, camper)
    decision_one, decision_two, week_two_lfa = decide(camper)
    bootcamper = camper.bootcamper
    camper_dlc_stack = if camper.dlc_stack
                         camper.dlc_stack.language_stack.name
                       else
                         "-"
                       end

    [
      serial_number, bootcamper.uuid, bootcamper.greenhouse_candidate_id,
      "#{bootcamper.first_name} #{bootcamper.last_name}",
      bootcamper.email, bootcamper.gender,
      camper.cycle_center.cycle_center_details[:center],
      camper.program.name, camper.cycle_center.start_date, camper_dlc_stack,
      camper.cycle_center.cycle_center_details[:cycle],
      camper.week_one_facilitator.email,
      week_two_lfa, decision_one, format_decision_reasons(camper, 1),
      get_decision_comment_by_stage(camper.decisions, 1),
      decision_two, format_decision_reasons(camper, 2),
      get_decision_comment_by_stage(camper.decisions, 2),
      camper.overall_average,
      camper.value_average, camper.output_average,
      camper.feedback_average
    ]
  end

  def get_camper_score(scores, phases)
    all_scores = {}
    scores.each do |score|
      all_scores[score.phase_id] = {} unless all_scores[score.phase_id]
      all_scores[score.phase_id][score.assessment_id] = score.score
    end
    get_camper_assessment_score(phases, all_scores)
  end

  def get_camper_assessment_score(phases, all_scores)
    camper_assessment_score = []
    phases.each do |phase|
      phase.assessments.ids.each do |assessment|
        if all_scores[phase.id] && all_scores[phase.id][assessment]
          camper_assessment_score << all_scores[phase.id][assessment]
        else
          camper_assessment_score << "-"
        end
      end
    end
    camper_assessment_score
  end

  def format_decision_reasons(camper, decision_stage)
    camper.
      decisions.
      select { |bdr| bdr.decision_stage == decision_stage }.
      map { |reason| reason.decision_reason.reason }.
      join(", ")
  end

  def get_decision_comment_by_stage(decisions, decision_stage)
    decisions.
      select { |decision| decision.decision_stage == decision_stage }.
      map(&:comment).uniq.join("")
  end

  def get_program(program_id)
    Program.find_by(id: program_id).name
  end

  def get_holistic_scores(camper_id, criteria)
    scores = {}
    evaluations = HolisticEvaluation.get_evaluations(camper_id)
    criteria.each { |criterium| scores[criterium[:id]] = [] }

    evaluations.each do |evaluation|
      scores.each_key do |key|
        scores[key] << evaluation.score if key == evaluation.criterium_id
      end
    end

    scores
  end

  def get_camper_holistic_data(camper_id, _program_id,
                               evaluation_count, criteria)
    holistic_score = get_holistic_scores(
      camper_id, criteria
    )
    holistic_data = []

    evaluation_count.times do |count|
      holistic_score.each do |key, score|
        holistic_data << if score.nil? || score[count].nil?
                           "-"
                         else
                           holistic_score[key][count]
                         end
      end
    end

    holistic_data
  end

  def holistic_csv_data(holistic_data)
    data_row = [
      holistic_data[:created_at][:date],
      Time.parse(holistic_data[:created_at][:time]).strftime("%I:%M %p"),
      holistic_data[:average]
    ]
    holistic_data[:details].map do |_key, value|
      data_row.concat([(value[:score]).to_s, (value[:comment]).to_s])
    end

    data_row
  end
end
