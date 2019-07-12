require "fancy_id"
require "roo"
require "assets/date_check"

class Bootcamper < ApplicationRecord
  self.primary_key = :camper_id
  validates :camper_id, uniqueness: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, presence: true, acceptance: { accept: %w(Male Female) }
  validates :uuid,
            uniqueness: { case_sensitive: false },
            allow_blank: true
  validates :greenhouse_candidate_id,
            uniqueness: { case_sensitive: false },
            allow_blank: true

  has_many :bootcampers_language_stacks,
           class_name: "BootcampersLanguageStack",
           primary_key: "camper_id",
           foreign_key: "camper_id"
  has_many :language_stacks, through: :bootcampers_language_stacks
  belongs_to :proficiency
  has_many :learner_programs,
           class_name: "LearnerProgram",
           primary_key: "camper_id",
           foreign_key: "camper_id"

  has_many :programs,
           through: :learner_programs

  has_many :bootcamper_cycle_centers,
           class_name: "BootcamperCycleCenter",
           primary_key: "camper_id",
           foreign_key: "camper_id"

  has_many :cycle_centers,
           through: :bootcamper_cycle_centers

  has_many :survey_responses, as: :respondable
  has_many :learners_pitches,
           primary_key: "camper_id",
           foreign_key: "camper_id"
  before_create do
    self.camper_id = Bootcamper.generate_camper_id
  end

  def self.generate_camper_id
    generate_id
  end

  def self.search(search_term, program_id)
    criteria = %w[email].
               push("first_name || ' ' || last_name").
               push("last_name || ' ' || first_name")
    query = criteria.map { |value| value + " ILIKE :search_term" }.join(" OR ")
    result = where(query, search_term: "%#{search_term}%").pluck(:camper_id)

    LearnerProgram.where(camper_id: result, program_id: program_id)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def self.get_lfa_name(email)
    email.split("@")[0].split(".").each(&:capitalize!).join(" ")
  end

  def self.arrange_learners(learner_programs)
    camper_list = []
    learner_programs.includes(
      :program, :week_one_facilitator, :week_two_facilitator,
      :decisions, :bootcamper, cycle_center: %i[center cycle]
    ).map do |learner_program|
      week_one_lfa = get_lfa(learner_program.week_one_facilitator)
      week_two_lfa = get_lfa(learner_program.week_two_facilitator)
      cycle_center = learner_program.cycle_center
      cycle_end_date = cycle_center ? cycle_center.end_date : ""
      camper_list << camper_list(learner_program, week_two_lfa,
                                 week_one_lfa, cycle_end_date)
    end
    camper_list
  end

  def self.get_lfa(lfa)
    get_lfa_name(lfa.email) unless lfa.blank?
  end

  def self.camper_list(learner_program,
                       week_two_lfa, week_one_lfa, cycle_end_date)
    camper = learner_program.bootcamper
    {
      created_at: learner_program.created_at,
      camper_id: learner_program.camper_id,
      program_id: learner_program.program_id,
      first_name: camper.first_name, last_name: camper.last_name,
      email: camper.email, gender: camper.gender,
      week_one_lfa: week_one_lfa, week_two_lfa: week_two_lfa,
      decision_one: learner_program.decision_one,
      decision_two: learner_program.decision_two,
      progress: learner_program.progress.to_i,
      decision_one_comment: get_decision_comment(
        learner_program.decisions, 1
      ),
      decision_two_comment: get_decision_comment(
        learner_program.decisions, 2
      ),
      overall_average: learner_program.overall_average,
      value_average: learner_program.value_average,
      output_average: learner_program.output_average,
      feedback_average: learner_program.feedback_average,
      learner_program_id: learner_program.id,
      cycle_ended: past_date?(cycle_end_date)
    }.merge(learner_program.cycle_center.cycle_center_details)
  end

  def self.get_decision_comment(decisions, stage)
    stage_decision = decisions.select do |decision|
      decision.decision_stage == stage
    end

    stage_decision[0].blank? ? "" : stage_decision[0].comment
  end

  def self.validate_camper(camper)
    if Bootcamper.
       find_by(greenhouse_candidate_id: camper[:greenhouse_candidate_id])
      bootcamper = Bootcamper.
                   find_by(greenhouse_candidate_id:
                   camper[:greenhouse_candidate_id])
    else
      bootcamper = Bootcamper.find_or_create_by(email: camper[:email].downcase)
    end
    bootcamper.update(
      email: camper[:email].downcase,
      first_name: camper[:first_name],
      last_name: camper[:last_name],
      gender: camper[:gender],
      greenhouse_candidate_id: camper[:greenhouse_candidate_id]
    )
    bootcamper
  end

  def self.learner_details(learner_program_id)
    LearnerProgram.includes(:bootcamper, cycle_center: %i(cycle center)).
      find(learner_program_id)
  end

  def self.get_preferred_languages_stacks(camper_id)
    BootcampersLanguageStack.joins(:language_stack).select(
      :id,
      :name
    ).where(camper_id: camper_id).pluck(:id, :name)
  end

  def self.update_preferred_languages_stacks(camper_id, new_languages_stacks)
    old_languages_stacks = []
    get_preferred_languages_stacks(camper_id).each do |langauge_stack|
      old_languages_stacks << langauge_stack[0]
    end
    (new_languages_stacks - old_languages_stacks).each do |language_stack_id|
      BootcampersLanguageStack.create(
        camper_id: camper_id, language_stack_id: language_stack_id
      )
    end

    BootcampersLanguageStack.where(
      camper_id: camper_id,
      language_stack_id: old_languages_stacks - new_languages_stacks
    ).delete_all
  end

  def avatar
    self[:avatar] || "https://ui-avatars.com/api/?name=#{self[:first_name]}+
                      #{self[:last_name]}&background=195BDC&color=fff&size=128"
  end

  def self.responded_to_survey_in_cycle(survey_id, cycle_id)
    Bootcamper.left_outer_joins(:survey_responses).joins(:learner_programs).
      where(
        "survey_responses.respondable_id IS NULL
      AND learner_programs.cycle_center_id
        = ? OR (survey_responses.new_survey_id
          != ? AND learner_programs.cycle_center_id
            = ?)", cycle_id, survey_id, cycle_id
      )
  end
end
