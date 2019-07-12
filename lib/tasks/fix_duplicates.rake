namespace :app do
  desc "Remove duplicated scores"
  task remove_duplicated_scores: :environment do
    remove_scores(26, 24, 923)
    remove_scores(24, 24, 924)
    remove_scores(32, 24, 938)
    remove_scores(7, 24, 934)
    remove_scores(11, 24, 934)
    remove_scores(17, 25, 940)
    remove_scores(40, 25, 940)
    remove_scores(31, 24, 994)
    remove_scores(31, 24, 994)
    remove_scores(14, 24, 1001)
  end

  desc "Remove errored scores"
  task remove_errored_scores: :environment do
    remove_scores(1, 25, 1834)
    remove_scores(1, 27, 2018)
    remove_scores(30, 29, 2665)
  end

  def remove_scores(assessment, phase, learner_program)
    score = Score.where(
      assessment_id: assessment,
      phase_id: phase,
      learner_programs_id: learner_program
    ).first
    score.delete
  end
end
