class AllprogramsObserver < ActiveRecord::Observer
  observe :program, :cadence, :phase, :framework, :criterium,
          :framework_criterium, :assessment
  def after_commit(_record)
    keys = RedisService.search("programspage:*")
    RedisService.delete_key(keys)
  end
end
