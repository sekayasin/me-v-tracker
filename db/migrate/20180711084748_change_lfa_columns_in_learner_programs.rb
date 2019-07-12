class ChangeLfaColumnsInLearnerPrograms < ActiveRecord::Migration[5.0]
  def up
    add_column :learner_programs, :week_one_facilitator_id, :string
    add_column :learner_programs, :week_two_facilitator_id, :string
    add_column :learner_programs, :week_one_facilitator, :string
    add_column :learner_programs, :week_two_facilitator, :string
    add_foreign_key :learner_programs,
     :facilitators, column: :week_one_facilitator_id
    add_foreign_key :learner_programs,
     :facilitators, column: :week_two_facilitator_id
    Rake::Task["app:convert_lfa_name_to_email"].invoke
    Rake::Task["db:populate_facilitators_table"].invoke
    Rake::Task["db:create_foreign_keys_to_facilitators_table"].invoke
    remove_column :learner_programs, :week_one_lfa
    remove_column :learner_programs, :week_two_lfa
    remove_column :learner_programs, :week_one_facilitator
    remove_column :learner_programs, :week_two_facilitator
  end

  def down
    add_column :learner_programs, :week_one_lfa, :string
    add_column :learner_programs, :week_two_lfa, :string
    Rake::Task["db:restore_data_on_lfa_columns"].invoke
    remove_column :learner_programs, :week_one_facilitator_id
    remove_column :learner_programs, :week_two_facilitator_id
    Rake::Task["db:clear_facilitators_table"].invoke
  end
end
