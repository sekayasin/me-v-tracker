class LearnerspageObserver < ActiveRecord::Observer
  observe :decision, :learner_program, :cycle, :notification,
          :cycle_center, :notifications_message, :facilitator, :bootcamper
  def after_commit(_record)
    keys = RedisService.search("learnerspage*")
    RedisService.delete_key(keys)
  end
end
