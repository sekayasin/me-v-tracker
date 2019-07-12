class CreatePitches < ActiveRecord::Migration[5.0]
  def change
    create_table :pitches do |t|
      t.string "cycle_center_id"
      t.date :demo_date

      t.timestamps
    end

    add_foreign_key :pitches, :cycles_centers, column: :cycle_center_id, primary_key: :cycle_center_id
  end
end
