class RemoveDescriptionFromFrameworks < ActiveRecord::Migration[5.0]
  def change
    remove_column :frameworks, :description, :text
  end
end
