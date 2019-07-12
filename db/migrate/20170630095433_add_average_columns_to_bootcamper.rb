class AddAverageColumnsToBootcamper < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :overall_average, :decimal, default: 0.0
    add_column :bootcampers, :week1_average, :decimal, default: 0.0
    add_column :bootcampers, :week2_average, :decimal, default: 0.0
    add_column :bootcampers, :project_average, :decimal, default: 0.0
    add_column :bootcampers, :value_average, :decimal, default: 0.0
    add_column :bootcampers, :output_average, :decimal, default: 0.0
    add_column :bootcampers, :feedback_average, :decimal, default: 0.0
  end
end
