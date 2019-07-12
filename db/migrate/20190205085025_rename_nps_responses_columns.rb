class RenameNpsResponsesColumns < ActiveRecord::Migration[5.0]
  def change
    rename_column :nps_responses, :nps_ratings_id, :primary_key
    rename_column :nps_responses, :nps_response_id, :nps_ratings_id
    rename_column :nps_responses, :primary_key, :nps_response_id
  end
end
