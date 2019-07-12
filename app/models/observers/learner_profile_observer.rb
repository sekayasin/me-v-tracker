class LearnerProfileObserver < ActiveRecord::Observer
  observe :learner_program, :center, :bootcamper,
          :assessment, :phase, :decision, :notification
  def after_commit(_record)
    keys = RedisService.search("learner_profile_*")
    RedisService.delete_key(keys)
  end
end
