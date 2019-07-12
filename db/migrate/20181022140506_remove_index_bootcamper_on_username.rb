class RemoveIndexBootcamperOnUsername < ActiveRecord::Migration[5.0]
  def change
    if index_exists?(:bootcampers, :username)
      remove_index :bootcampers, :username
    end
  end
end
