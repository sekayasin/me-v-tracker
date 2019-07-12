class AddSaveStatusToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :save_status, :string
  end
end
