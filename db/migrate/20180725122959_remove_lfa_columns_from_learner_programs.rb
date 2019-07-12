class RemoveLfaColumnsFromLearnerPrograms < ActiveRecord::Migration[5.0]
  def up
    Rake::Task["db:populate_facilitators_table"].invoke
    Rake::Task["db:create_foreign_keys_to_facilitators_table"].invoke
    remove_column :learner_programs, :week_one_lfa
    remove_column :learner_programs, :week_two_lfa
  end

  def down
    add_column :learner_programs, :week_one_lfa, :string
    add_column :learner_programs, :week_two_lfa, :string
    Rake::Task["db:restore_data_on_lfa_columns"].invoke
  end
end
