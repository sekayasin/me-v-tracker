class Score < ApplicationRecord
  belongs_to :learner_program, foreign_key: "learner_programs_id"
  belongs_to :assessment, -> { with_deleted }
  belongs_to :phase
  validates_presence_of :score, :phase_id, :assessment_id

  def self.save_score(params, learner_program_id)
    score = Score.find_or_create_by(
      learner_programs_id: learner_program_id,
      phase_id: params[:phase_id],
      assessment_id: params[:assessment_id]
    )
    score.update_attributes(
      score: params[:score],
      comments: params[:comments]
    )
  end

  def self.get_bootcamper_scores(learner_program_id)
    Score.where("learner_programs_id = ?", learner_program_id)
  end

  def self.total_assessed(learner_program_id)
    Score.where(learner_programs_id: learner_program_id).size
  end

  def self.overall_average(learner_program_id)
    camper_score = get_bootcamper_scores(learner_program_id).sum(:score)
    camper_assessment_count = total_assessed(learner_program_id)
    if camper_score.zero?
      0.0
    else
      (camper_score / camper_assessment_count).round(1)
    end
  end

  def self.framework_averages(learner_program_id)
    framework_averages = []
    vof = ["Values Alignment", "Output Quality", "Feedback"]
    frameworks = Framework.where(name: vof).order("name DESC")

    frameworks.each do |framework|
      framework_scores = framework.scores.select do |score|
        score.learner_programs_id == learner_program_id.to_i
      end

      framework_averages << framework.average_score(
        learner_program_id,
        framework_scores.count
      )
    end

    framework_averages
  end
end
