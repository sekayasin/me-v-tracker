class SubmissionspageObserver < ActiveRecord::Observer
  observe :feedback, :learner_program, :output_submission, :facilitator,
          :bootcamper
  def after_commit(_record)
    keys = RedisService.search("submissionspage*")
    RedisService.delete_key(keys)
  end
end
