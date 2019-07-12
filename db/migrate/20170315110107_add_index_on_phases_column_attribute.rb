class AddIndexOnPhasesColumnAttribute < ActiveRecord::Migration[5.0]
  def change
    add_index :phases, :name
  end
end
