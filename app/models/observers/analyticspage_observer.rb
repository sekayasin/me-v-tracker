class AnalyticspageObserver < ActiveRecord::Observer
  observe :learner_program, :criterium, :program,
          :cycle_center, :bootcamper
  def after_commit(_record)
    keys = RedisService.search("analytics*")
    RedisService.delete_key(keys)
  end
end
