class AddGenderToBootcampers < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :gender, :string
  end
end
