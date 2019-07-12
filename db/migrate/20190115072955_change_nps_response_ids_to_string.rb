class ChangeNpsResponseIdsToString < ActiveRecord::Migration[5.0]
  def change
    change_column :nps_responses, :camper_id, :string
    execute 'ALTER TABLE nps_responses ALTER COLUMN learner_program_id TYPE integer USING (learner_program_id::integer)'
  end
end
