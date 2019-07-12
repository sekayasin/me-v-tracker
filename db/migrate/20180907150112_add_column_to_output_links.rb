class AddColumnToOutputLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :output_links, :description, :text
    rename_table :output_links, :output_submissions
  end
end
