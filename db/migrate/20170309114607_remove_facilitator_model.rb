class RemoveFacilitatorModel < ActiveRecord::Migration[5.0]
  def up
    remove_foreign_key :scores, column: :facilitator_id
    remove_column :scores, :facilitator_id
    drop_table :facilitators
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
