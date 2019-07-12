class AddUuidToBootcampers < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :uuid, :string
  end
end
