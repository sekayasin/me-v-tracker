class AddCamperIdToNpsResponses < ActiveRecord::Migration[5.0]
    def change
      add_column :nps_responses, :camper_id, :integer
      add_index :nps_responses, :camper_id
    end
  end