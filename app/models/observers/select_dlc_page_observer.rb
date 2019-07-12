class SelectDlcPageObserver < ActiveRecord::Observer
  observe :point, :criterium, :program, :bootcamper
  def after_commit(_record)
    keys = RedisService.search("select-dlc*")
    RedisService.delete_key(keys)
  end
end
