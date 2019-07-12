class CreateAverageRatings < ActiveRecord::Migration[5.0]
  def change
    create_view :average_ratings
  end
end
