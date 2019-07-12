class RenameNpsResponsesToNpsRatings < ActiveRecord::Migration[5.0]
    def change
      rename_table :nps_ratings, :temp
      rename_table :nps_responses, :nps_ratings
      rename_table :temp, :nps_responses
      rename_column :nps_ratings, :nps_response_id, :nps_ratings_id
      Rake::Task['db:add_ratings_to_nps_ratings_table'].invoke
    end
  end
  