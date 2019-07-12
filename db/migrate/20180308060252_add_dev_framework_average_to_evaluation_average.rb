class AddDevFrameworkAverageToEvaluationAverage < ActiveRecord::Migration[5.0]
  def change
    add_column :evaluation_averages, :dev_framework_average, :decimal

    Rake::Task["app:recalculate_evaluation_averages"].invoke
  end
end
