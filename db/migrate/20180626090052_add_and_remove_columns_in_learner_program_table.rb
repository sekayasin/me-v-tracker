class AddAndRemoveColumnsInLearnerProgramTable < ActiveRecord::Migration[5.0]
  def up
    add_column :learner_programs, :cycle_center_id, :string
    Rake::Task["app:update_start_end_dates"].invoke
    Rake::Task["db:populate_new_cycle_centers_and_their_bootcampers"].invoke
    Rake::Task["db:update_learner_program_cycle_center"].invoke
    remove_column :learner_programs, :cycle, :string
    remove_column :learner_programs, :city, :string
    remove_column :learner_programs, :country, :string
    remove_column :learner_programs, :start_date, :date
    remove_column :learner_programs, :end_date, :date
  end

  def down
    add_column :learner_programs, :cycle, :string
    add_column :learner_programs, :city, :string
    add_column :learner_programs, :country, :string
    add_column :learner_programs, :start_date, :date
    add_column :learner_programs, :end_date, :date
    Rake::Task["db:restore_learner_programs_cycle_center"].invoke
    remove_column :learner_programs, :cycle_center_id, :string
  end
end
