class CreateYears < ActiveRecord::Migration[5.0]
  def up
    create_table :years, id: false do |t|
      t.string :year_id
      t.string :year, default: Time.now.year

      t.timestamps
    end
    execute 'ALTER TABLE years ADD PRIMARY KEY (year_id);'
  end

  def down
    execute 'ALTER TABLE years DROP CONSTRAINT years_pkey'
    drop_table :years
  end
end
