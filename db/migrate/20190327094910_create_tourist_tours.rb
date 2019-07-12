class CreateTouristTours < ActiveRecord::Migration[5.0]
  def change
    create_table :tourist_tours do |t|
      t.string :tourist_email
      t.references :tour, foreign_key: true
      t.text :role

      t.timestamps
    end
  end
end
