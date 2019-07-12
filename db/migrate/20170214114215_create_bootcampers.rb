class CreateBootcampers < ActiveRecord::Migration[5.0]
  def change
    create_table :bootcampers do |t|
      t.integer :camper_id
      t.string :week_one_lfa

      t.timestamps
    end
  end
end
