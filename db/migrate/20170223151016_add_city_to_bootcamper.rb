class AddCityToBootcamper < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :city, :string
    add_column :bootcampers, :country, :string
    remove_column :bootcampers, :location, :string
  end
end
