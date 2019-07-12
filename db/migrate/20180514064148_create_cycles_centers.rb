class CreateCyclesCenters < ActiveRecord::Migration[5.0]
  def up
    create_table :cycles_centers, id: false do |t|
      t.string :cycle_center_id, primary: true, index: true
      t.string :center_id
      t.string :cycle_id
      t.date :start_date
      t.date :end_date
      t.references :program, foreign_key: true

      t.timestamps
    end
    Rake::Task["db:populate_cycles_centers_table"].invoke
  end

  def down
    drop_table(:cycles_centers, if_exists: true)
  end
end
