class AddProgressPercentageToBootcampers < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :progress_percentage, :integer
  end
end
