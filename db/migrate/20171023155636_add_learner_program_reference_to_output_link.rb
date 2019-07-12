class AddLearnerProgramReferenceToOutputLink < ActiveRecord::Migration[5.0]
  def change
    remove_index :output_links, %i(camper_id assessment_id phase_id)

    remove_foreign_key :output_links, :bootcampers
    remove_column :output_links, :camper_id, :string

    add_column :output_links, :learner_programs_id, :integer
    add_foreign_key :output_links, :learner_programs, column: :learner_programs_id, primary_key: :id

    add_index :output_links, %i(learner_programs_id assessment_id phase_id), unique: true, name: 'unique_output_link'
  end
end
