class RemovePhasesColumnAttribute < ActiveRecord::Migration[5.0]
  def change
    remove_index :phases, :name
  end
end
