class AddProgramYearsReferenceToLearnerPrograms < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :learner_programs, :program_years, column: :program_year_id, primary_key: :program_year_id
    add_index :learner_programs, :program_year_id
    Rake::Task["db:populate_program_year_id_on_learner_programs_table"].invoke
  end
end
