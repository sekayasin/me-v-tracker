class AddDescriptionToCriteria < ActiveRecord::Migration[5.0]
  def change
    add_column :criteria, :description, :text
  end
end
