class AddOverallAverageToBootcamper < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :overall_average, :string
  end
end
