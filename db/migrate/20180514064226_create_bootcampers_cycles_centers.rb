class CreateBootcampersCyclesCenters < ActiveRecord::Migration[5.0]
  def up
    create_table :bootcampers_cycles_centers, id: false do |t|
      t.string :bcc_id, primary: true, index: true
      t.string :camper_id
      t.string :cycle_center_id
      t.timestamps
    end

    Rake::Task["db:populate_bootcampers_cycles_centers_table"].invoke
  end

  def down
    drop_table(:bootcampers_cycles_centers, if_exists: true)
  end
end
