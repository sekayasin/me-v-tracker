class ChangePrimaryKey < ActiveRecord::Migration[5.0]
  def change
    remove_column :bootcampers, :id # remove existing primary key
    execute "ALTER TABLE bootcampers ADD PRIMARY KEY (camper_id);"
  end
end
