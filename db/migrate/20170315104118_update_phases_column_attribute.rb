class UpdatePhasesColumnAttribute < ActiveRecord::Migration[5.0]
  def change
    add_index :phases, :name, unique: true
  end
end
