class CreateProgramsPhases < ActiveRecord::Migration[5.0]
  def up
    create_table :programs_phases do |t|
      t.references :program, foreign_key: true
      t.references :phase, foreign_key: true

      t.timestamps

    end
  end

  def down
    drop_table(:programs_phases, if_exists: true)
  end
end
