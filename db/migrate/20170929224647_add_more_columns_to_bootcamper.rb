class AddMoreColumnsToBootcamper < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :phone_number, :string
    add_column :bootcampers, :about, :text
    add_column :bootcampers, :last_seen_at, :datetime
  end
end
