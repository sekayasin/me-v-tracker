class LearningEcosystemObserver < ActiveRecord::Observer
  observe :assessment, :phase, :program, :learner_program,
          :programs_phase, :output_submission

  def after_commit(_record)
    keys = RedisService.search("learning_ecosystem*")
    RedisService.delete_key(keys)
  end
end
