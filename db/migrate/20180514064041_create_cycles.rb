class CreateCycles < ActiveRecord::Migration[5.0]
  def up
    create_table :cycles, id: false do |t|
      t.integer :cycle
      t.string :cycle_id, primary: true, index: true

      t.timestamps
    end
    Rake::Task["db:populate_cycles_table"].invoke
  end

  def down
    drop_table(:cycles, if_exists: true)
  end
end
