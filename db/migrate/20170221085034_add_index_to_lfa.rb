class AddIndexToLfa < ActiveRecord::Migration[5.0]
  def change
    add_index :bootcampers, :week_one_lfa
  end
end
