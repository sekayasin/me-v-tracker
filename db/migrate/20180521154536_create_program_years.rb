class CreateProgramYears < ActiveRecord::Migration[5.0]
  def up
    create_table :program_years, id: false do |t|
      t.string :program_year_id
      t.string :year_id
      t.string :target_id
      t.references :program, foreign_key: true
      t.timestamps
    end
    add_index :program_years, :program_year_id
    execute 'ALTER TABLE program_years ADD PRIMARY KEY (program_year_id);'
    add_foreign_key :program_years, :targets, column: :target_id, primary_key: :target_id
    add_foreign_key :program_years, :years, column: :year_id, primary_key: :year_id
  end

  def down
    remove_index :program_years, :program_year_id    
    execute 'ALTER TABLE program_years DROP CONSTRAINT program_years_pkey'
    drop_table :program_years
  end
end
