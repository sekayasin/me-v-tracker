class CarriculapageObserver < ActiveRecord::Observer
  observe :framework, :criterium, :assessment, :program,
          :metric, :framework_criterium, :point, :programs_phase

  def after_commit(_record)
    keys = RedisService.search("curricula_page:*")
    RedisService.delete_key(keys)
  end
end
