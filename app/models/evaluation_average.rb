class EvaluationAverage < ApplicationRecord
  has_many :holistic_evaluations
  validates :holistic_average, :dev_framework_average, presence: true

  def self.calculate_average(scores)
    (scores.sum.to_f / scores.length).round(1)
  end

  def self.get_existing_average(learner_program_id, dev_framework_only = false)
    scores = if dev_framework_only
               HolisticEvaluation.get_scores(learner_program_id, true)
             else
               HolisticEvaluation.get_scores(learner_program_id)
             end
    scores.empty? ? 0.0 : calculate_average(scores)
  end

  def self.save_evaluation_averages(
    holistic_scores,
    dev_framework_scores,
    learner_program_id
  )

    evaluations = HolisticEvaluation.where(
      learner_program_id: learner_program_id
    )

    unless evaluations.empty?
      return update_averages(
        holistic_scores,
        dev_framework_scores,
        learner_program_id
      )
    end

    holistic_average = calculate_average(holistic_scores)
    dev_framework_average = calculate_average(dev_framework_scores)

    create(
      holistic_average: holistic_average,
      dev_framework_average: dev_framework_average
    )
  end

  def self.update_averages(
    holistic_scores,
    dev_framework_scores,
    learner_program_id
  )

    existing_holistic_scores = HolisticEvaluation.get_scores(learner_program_id)
    holistic_scores += existing_holistic_scores

    existing_dev_framework_scores = HolisticEvaluation.
                                    get_scores(learner_program_id, true)
    dev_framework_scores += existing_dev_framework_scores

    new_holistic_average = calculate_average(holistic_scores)
    new_dev_framework_average = calculate_average(dev_framework_scores)

    evaluation_average = HolisticEvaluation.
                         get_average_by_learner_id(learner_program_id)

    evaluation_average.update_attributes(
      holistic_average: new_holistic_average,
      dev_framework_average: new_dev_framework_average
    )
    evaluation_average
  end
end
