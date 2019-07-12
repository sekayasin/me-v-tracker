class AddDescriptionToFrameworks < ActiveRecord::Migration[5.0]
  def change
    add_column :frameworks, :description, :text
  end
end
