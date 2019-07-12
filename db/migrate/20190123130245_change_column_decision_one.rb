class ChangeColumnDecisionOne < ActiveRecord::Migration[5.0]
  def change
    change_column :learner_programs, :decision_one, :string, default: "In Progress"
    Rake::Task['app:set_decision_one_to_default_value'].invoke
  end
end
