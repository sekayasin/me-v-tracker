class AddFinalizedColumnToFeedbackTable < ActiveRecord::Migration[5.0]
  def change
    add_column :feedback, :finalized, :boolean, :default => false
    Rake::Task['db:set_existing_feedback_to_finalized'].invoke
  end
end
