class AddCriteriaToMetrics < ActiveRecord::Migration[5.0]
  def change
    add_reference :metrics, :criteria, foreign_key: true
    Rake::Task["db:populate_criteria_points"].invoke
  end
end
