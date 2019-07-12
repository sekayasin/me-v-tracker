class AddDecisionStatusAndCommentToBootcamperDecisionReasons < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcamper_decision_reasons, :comment, :text
    add_timestamps :bootcamper_decision_reasons, default: Time.now
  end
end
