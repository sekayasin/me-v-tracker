class AddCycleToBootcamper < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :cycle, :string
  end
end
