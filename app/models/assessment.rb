class Assessment < ApplicationRecord
  acts_as_paranoid
  belongs_to :framework_criterium
  has_one :framework, through: :framework_criterium
  has_one :criterium, through: :framework_criterium
  has_many :output_submissions, dependent: :destroy
  has_and_belongs_to_many :phases, (-> { distinct })
  has_many :scores
  has_many :feedback
  has_many :metrics, -> { order(point_id: :asc) }, inverse_of: :assessment
  accepts_nested_attributes_for :metrics
  has_many :submission_phases, class_name: "AssessmentOutputSubmission"
  validates :framework_criterium_id, presence: true
  validates :name, presence: true, uniqueness: true
  validates :context, presence: true
  validates :description, presence: true

  def self.get_framework_assessments(framework_id)
    joins(:framework_criterium).where(
      framework_criteria: {
        framework_id: framework_id
      }
    )
  end

  def self.get_total_assessments(program_id)
    phases = ProgramsPhase.where(program_id: program_id).pluck(:phase_id)
    connection = ActiveRecord::Base.connection
    count = connection.execute(
      "select count(id) from assessments_phases where phase_id IN (
        #{phases.join(',')}
      )"
    )
    count[0]["count"]
  end

  def self.get_required_submissions_count(phases)
    Assessment.includes(:phases).
      where(requires_submission: true, "phases.id" => phases).ids.size
  end

  def self.get_assessments_by_phase(phase_id)
    Phase.includes(assessments: [:framework]).find_by(id: phase_id)
  end

  def get_details_by_phase(phase_id)
    Assessment.joins(:phases, :framework, :criterium).
      where("phases.id = ?", phase_id).select(
        'frameworks.id as framework_id, frameworks.name as framework_name,
        assessments.name as assessment_name, assessments.id as assessment_id,
        criteria.id as criteria_id, criteria.name as criteria_name'
      )
  end

  def self.get_assessments_by_program(program_id,
                                      search_term = "",
                                      pagination_params = {})

    assessment_ids = []
    unless program_id == "All"
      assessment_ids = Program.joins(phases: :assessments).
                       where(id: program_id.to_i).
                       pluck("assessments.id").uniq
    end
    assessments = build_assessments(pagination_params,
                                    program_id,
                                    assessment_ids)
    if search_term.blank?
      yield_assessments(pagination_params, assessments)
    else
      fields = %w(name description expectation context)
      result = fields.map { |field| "#{field} ILIKE :search_term" }
      query = result.join(" OR ")
      assessments.where(query, search_term: "%#{search_term}%")
    end
  end

  def duration(program_id)
    ProgramsPhase.
      includes(:phase).
      where(program_id: program_id.to_i, phase_id: phases).
      first.phase.phase_duration
  end

  def get_program_assessments_per_phase(program_id)
    phases = Program.find_by!(id: program_id).
             phases.includes(:assessments).
             order("id ASC")
    assessments = []

    phases.each do |phase|
      data = get_details_by_phase(phase.id)

      assessments.push(
        phase_id: phase.id,
        assessments: data,
        phase_duration: phase.phase_duration,
        phase_name: phase.name,
        phase_decision: phase.phase_decision_bridge
      )
    end
    assessments
  end

  def self.build_assessments(pagination_params, program_id, assessment_ids)
    resolve = -> { program_id == "All" ? {} : { id: assessment_ids } }
    if pagination_params.blank?
      includes(:framework, :criterium, :phases, metrics: :point).
        where(resolve.call)
    else
      page(pagination_params[:offset]).
        per(pagination_params[:limit]).
        includes(:framework, :criterium, :phases,
                 metrics: :point).
        where(resolve.call)
    end
  end

  def self.yield_assessments(pagination_params, assessments)
    return assessments unless pagination_params[:count].present?

    { assessments: assessments, count: assessments.total_count }
  end

  private_class_method :build_assessments, :yield_assessments
end
