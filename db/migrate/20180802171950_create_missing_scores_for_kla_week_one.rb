class CreateMissingScoresForKlaWeekOne < ActiveRecord::Migration[5.0]
  def change
    Rake::Task["app:create_missing_scores_for_kla_week_one"].invoke
  end
end
