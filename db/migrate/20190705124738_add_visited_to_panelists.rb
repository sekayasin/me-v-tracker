class AddVisitedToPanelists < ActiveRecord::Migration[5.0]
  def change
    add_column :panelists, :visited, :boolean, null: false, default: false
  end
end
