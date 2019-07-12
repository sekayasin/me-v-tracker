class HolisticEvaluation < ApplicationRecord
  belongs_to :learner_program
  belongs_to :criterium, -> { with_deleted }
  belongs_to :evaluation_average

  validates_presence_of :learner_program_id,
                        :criterium_id,
                        :evaluation_average_id,
                        :score

  validates_associated :learner_program,
                       :criterium,
                       :evaluation_average

  def self.get_evaluations(learner_program_id)
    where(learner_program_id: learner_program_id).includes(
      :criterium, :evaluation_average
    ).order(created_at: :asc)
  end

  def self.get_average_by_learner_id(learner_program_id)
    holistic_evaluation = find_by_learner_program_id(learner_program_id)
    holistic_evaluation.nil? ? nil : holistic_evaluation.evaluation_average
  end

  def self.get_scores(learner_program_id, dev_framework_only = false)
    if dev_framework_only
      joins(:criterium).
        where(
          "holistic_evaluations.learner_program_id = ? AND \
                  criteria.belongs_to_dev_framework = ?",
          learner_program_id,
          true
        ).
        pluck(:score)
    else
      where(learner_program_id: learner_program_id).
        pluck(:score)
    end
  end

  def self.parse_evaluation_scores(evaluations, dev_framework_only = false)
    scores = []

    dev_framework_criteria_ids = Criterium.get_dev_framework_criteria_ids

    evaluations.each_value do |evaluation|
      if dev_framework_only &&
         dev_framework_criteria_ids.include?(evaluation[:criterium_id].to_i)
        scores << evaluation[:score].to_i
      elsif !dev_framework_only
        scores << evaluation[:score].to_i
      end
    end

    scores
  end

  def self.program_max_evaluations(program_id)
    # get highest number of evaluations provided for a program
    evaluations = joins(:learner_program).
                  where("learner_programs.program_id = ?", program_id)

    return 0 if evaluations.blank?

    learner_program_ids = evaluations.pluck(:learner_program_id)
    scored_criteria = evaluations.select(:criterium_id).distinct.length

    count = learner_program_ids.count(
      learner_program_ids.max_by { |id| learner_program_ids.count(id) }
    )

    count.zero? ? 0 : count / scored_criteria
  end

  def self.save_holistic_evaluations(
    holistic_evaluations,
    learner_program_id,
    evaluation_average_id
  )
    holistic_evaluations.each_value do |evaluation|
      create!(
        learner_program_id: learner_program_id,
        criterium_id: evaluation[:criterium_id],
        score: evaluation[:score],
        comment: evaluation[:comment],
        evaluation_average_id: evaluation_average_id
      )
    end
  end

  def self.update_holistic_evaluations(
    holistic_evaluations
  )
    holistic_evaluations.each_value do |evaluation|
      HolisticEvaluation.where(id: evaluation[:id]).update(
        score: evaluation[:score],
        comment: evaluation[:comment]
      )
    end
  end
end
