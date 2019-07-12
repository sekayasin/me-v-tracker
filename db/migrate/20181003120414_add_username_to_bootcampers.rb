class AddUsernameToBootcampers < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :username, :string
    add_index :bootcampers, :username, unique: true
  end
end
