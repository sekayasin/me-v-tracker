class LearnerProgram < ApplicationRecord
  include EvaluationEligibility

  belongs_to :program
  belongs_to :bootcamper, foreign_key: :camper_id
  belongs_to :dlc_stack, foreign_key: :dlc_stack_id
  belongs_to :cycle_center
  belongs_to :week_one_facilitator, class_name: "Facilitator"
  belongs_to :week_two_facilitator, class_name: "Facilitator"

  has_many :feedback
  has_many :holistic_evaluations
  has_many :holistic_feedback

  has_many :output_submissions,
           foreign_key: "learner_programs_id", dependent: :destroy

  has_many :decisions,
           class_name: "Decision",
           primary_key: "id",
           foreign_key: "learner_programs_id"

  has_many :decision_reasons,
           class_name: "DecisionReason",
           foreign_key: "learner_programs_id",
           through: "decisions"

  has_many :scores,
           class_name: "Score",
           primary_key: "id",
           foreign_key: "learner_programs_id"

  has_many :program_years,
           class_name: "ProgramYear",
           primary_key: "program_year_id",
           foreign_key: "program_year_id"

  scope :newest_first, -> { order(id: :desc) }

  def self.lfas(city, cycle, week = 1)
    lfas = LearnerProgram.where(
      centers: { name: city },
      cycles: { cycle: cycle }
    ).
           joins(cycle_center: :center).
           joins(cycle_center: :cycle).
           references(:week_one_facilitator, :week_two_facilitator)
    facilitators = lfas.map(&:week_one_facilitator).to_set.to_a if week == 1
    facilitators = lfas.map(&:week_two_facilitator).to_set.to_a if week == 2
    facilitators || []
  end

  def self.get_decision_reasons(decision_stage, learner_program_id = nil)
    Decision.
      where(
        decision_stage: decision_stage,
        learner_programs_id: learner_program_id
      ).
      map { |value| value.decision_reason.reason }
  end

  def self.update_scores(data)
    score = {}
    score[:progress] = progress_percentage(
      data[:score],
      data[:total]
    )
    score[:overall_average] = Score.overall_average(
      data[:learner_program_id]
    )
    score[:framework_averages] = Score.framework_averages(
      data[:learner_program_id]
    )

    score
  end

  def self.progress_percentage(score, total)
    total.positive? ? (score * 100 / total).round : nil
  end

  def self.update_campers_progress(data)
    camper_score = update_scores(data)

    LearnerProgram.find_by(id: data[:learner_program_id]).update(
      progress: camper_score[:progress],
      overall_average: camper_score[:overall_average],
      value_average: camper_score[:framework_averages][0],
      output_average: camper_score[:framework_averages][1],
      feedback_average: camper_score[:framework_averages][2]
    )
  end

  def self.cycles(program_id, city)
    CycleCenter.includes(:center, :cycle).
      where(program_id: program_id, centers: { name: city }).
      map(&:cycle).to_set.to_a.pluck(:cycle).
      sort_by { |cycle| 0 - cycle.to_i }
  end

  def self.get_gender_count(program_id, city, cycle, gender)
    joins(:bootcamper).
      joins(cycle_center: :center).
      joins(cycle_center: :cycle).where(
        program_id: program_id,
        centers: { name: city },
        cycles: { cycle: cycle },
        bootcampers: { gender: gender }
      )
  end

  def self.get_existing_program(program_id, city, program_cycle)
    joins(cycle_center: :center).
      joins(cycle_center: :cycle).
      find_by(
        program_id: program_id,
        centers: { name: city },
        cycles: { cycle: program_cycle }
      )
  end

  def self.program_locations(program_id)
    query = { program_id: program_id }
    CycleCenter.where(query).includes(
      :center
    ).pluck(:name).reject(&:nil?).sort.uniq
  end

  def self.programs
    Program.where(save_status: "true").order(name: :asc)
  end

  def self.get_phase_impression(learner_program_id)
    {
      phases: LearnerProgram.where(id: learner_program_id).last.program.phases,
      impressions: Impression.all
    }
  rescue NoMethodError
  end

  def self.get_all_learner_feedback(email)
    Bootcamper.where(email: email).last.learner_programs.last
  end

  def self.learner_cycle(learner)
    cycle_center_details = learner.cycle_center.cycle_center_details
    {
      cycle: cycle_center_details[:cycle],
      center: cycle_center_details[:center],
      country: cycle_center_details[:country],
      start_date: cycle_center_details[:start_date],
      end_date: cycle_center_details[:end_date]
    }
  end

  def self.get_learner_programs(camper_id)
    learner_programs = Array.new
    query = includes(
      :program,
      cycle_center: %i(center cycle)
    ).where(camper_id: camper_id)

    query.each do |learner_program|
      learner_programs << {
        id: learner_program.id,
        program: learner_program.program.name,
        decision_one: learner_program.decision_one,
        decision_two: learner_program.decision_two,
        created_at: learner_program.created_at.strftime("%Y-%m-%d")
      }.merge(learner_cycle(learner_program))
    end

    learner_programs
  end

  def self.get_latest_learner_program(camper_id, query = [])
    LearnerProgram.includes(query).where(camper_id: camper_id).last
  end

  def self.average_of_cycle_in_city(program_id, average_type, city, cycle)
    average = where(program_id: program_id,
                    centers: { name: city },
                    cycles: { cycle: cycle },
                    decision_two: "Accepted").
              joins(cycle_center: :center).
              joins(cycle_center: :cycle).
              average(average_type)

    average.nil? ? 0 : average
  end

  def self.evaluations_of_cycle_in_city(program_id, average_type, city, cycle)
    evaluation_ids = where(program_id: program_id,
                           cycles: { cycle: cycle },
                           centers: { name: city },
                           decision_two: "Accepted").
                     includes(:holistic_evaluations).
                     joins(cycle_center: :center).
                     joins(cycle_center: :cycle).
                     pluck(:evaluation_average_id).uniq

    total_evaluation_average = EvaluationAverage.
                               where(id: evaluation_ids).
                               average(average_type)

    total_evaluation_average.nil? ? 0 : total_evaluation_average
  end

  def self.week_one_decisions
    decisions = []
    DecisionStatus.all.each { |decision| decisions << decision.status }
    decisions - ["In Progress", "Accepted", "Fast-tracked"]
  end

  def self.get_learner_alc_languages_stacks(camper_id)
    joins(dlc_stack: :language_stack).select(
      "language_stacks.name"
    ).where(camper_id: camper_id).distinct.pluck("language_stacks.name")
  end

  def ongoing?
    cycle_center.end_date && cycle_center.end_date >= Date.today
  end

  def self.active
    LearnerProgram.where(cycle_center: CycleCenter.active)
  end

  def active_lfa
    if week_two_facilitator.email == "unassigned@andela.com"
      return week_one_facilitator
    end

    week_two_facilitator
  end

  def active_learner?(learner)
    decision = learner.decision_one
    ["In Progress", "Advanced"].include?(decision)
  end
end
