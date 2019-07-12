class UpdateColumnsInFacililators < ActiveRecord::Migration[5.0]
  def up
    remove_column :facilitators, :first_name
    remove_column :facilitators, :last_name
    remove_column :facilitators, :city
    remove_column :facilitators, :country
    add_column :facilitators, :facilitator_id, :string
    add_index :facilitators, :email, unique: true
    remove_column :facilitators, :id
    rename_column :facilitators, :facilitator_id, :id
    execute "ALTER TABLE facilitators ADD PRIMARY KEY (id);"
  end

  def down
    add_column :facilitators, :first_name, :string
    add_column :facilitators, :last_name, :string
    add_column :facilitators, :city, :string
    add_column :facilitators, :country, :string
  end
end
