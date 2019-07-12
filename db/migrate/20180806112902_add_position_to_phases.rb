class AddPositionToPhases < ActiveRecord::Migration[5.0]
  def change
    add_column :phases, :position, :integer
  end
end
