class RemoveBootcampColumns < ActiveRecord::Migration[5.0]
  def change

    remove_column :bootcampers, :week_one_lfa, :string
    remove_column :bootcampers, :week_two_lfa, :string
    remove_column :bootcampers, :decision_one, :string
    remove_column :bootcampers, :decision_two, :string
    remove_column :bootcampers, :progress_week1, :integer
    remove_column :bootcampers, :progress_week2, :integer
    remove_column :bootcampers, :overall_average, :decimal
    remove_column :bootcampers, :week1_average, :decimal
    remove_column :bootcampers, :week2_average, :decimal
    remove_column :bootcampers, :project_average, :decimal
    remove_column :bootcampers, :value_average, :decimal
    remove_column :bootcampers, :output_average, :decimal
    remove_column :bootcampers, :feedback_average, :decimal
    remove_column :bootcampers, :decision_one_comment, :text
    remove_column :bootcampers, :decision_two_comment, :text
    remove_column :bootcampers, :cycle, :string
    remove_column :bootcampers, :city, :string
    remove_column :bootcampers, :country, :string
    remove_column :bootcampers, :program_id, :integer

    remove_foreign_key :scores, :bootcampers
    remove_column :scores, :camper_id, :integer

    remove_foreign_key :bootcamper_decision_reasons, :bootcampers
    remove_column :bootcamper_decision_reasons, :camper_id, :integer

  end
end
