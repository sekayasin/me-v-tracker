class AddColumnsToBootcamper < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :first_name, :string
    add_column :bootcampers, :last_name, :string
    add_column :bootcampers, :email, :string
    add_column :bootcampers, :week_one_score, :string
    add_column :bootcampers, :week_two_score, :string
    add_column :bootcampers, :final_score, :string
    add_column :bootcampers, :week_two_lfa, :string
    add_column :bootcampers, :location, :string
    add_column :bootcampers, :status, :string
  end
end
