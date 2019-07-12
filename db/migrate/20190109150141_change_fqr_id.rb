class ChangeFqrId < ActiveRecord::Migration[5.0]
  def change
    rename_column :nps_ratings, :fqr_id, :nps_ratings_id
  end
end
