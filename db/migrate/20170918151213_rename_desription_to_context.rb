class RenameDesriptionToContext < ActiveRecord::Migration[5.0]
  def change
    rename_column :assessments, :description, :context
  end
end
