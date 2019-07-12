class AddShowAgainToNpsRatings < ActiveRecord::Migration[5.0]
  def change
    add_column :nps_ratings, :show_again, :Boolean
    add_index :nps_ratings, :show_again
  end
end
