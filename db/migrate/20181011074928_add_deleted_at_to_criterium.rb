class AddDeletedAtToCriterium < ActiveRecord::Migration[5.0]
  def change
    add_column :criteria, :deleted_at, :datetime
    add_index :criteria, :deleted_at
  end
end
