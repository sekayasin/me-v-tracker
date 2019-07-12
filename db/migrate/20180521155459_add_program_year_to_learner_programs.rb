class AddProgramYearToLearnerPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :learner_programs, :program_year_id, :string
    Rake::Task["db:populate_year_and_target_table"].invoke
  end
end
