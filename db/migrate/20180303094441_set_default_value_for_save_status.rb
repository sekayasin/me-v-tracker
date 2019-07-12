class SetDefaultValueForSaveStatus < ActiveRecord::Migration[5.0]
  def up
    change_column :programs, :save_status, 'boolean USING CAST(save_status AS boolean)', default: false
  end
  def down
    change_column :programs, :save_status, :string
  end
end
