class CreateTargets < ActiveRecord::Migration[5.0]
  def up
    create_table :targets, id: false do |t|
      t.string :target_id, null: true
      t.decimal :value, default: "0.0"
      t.timestamps
    end
    execute 'ALTER TABLE targets ADD PRIMARY KEY (target_id);'
  end

  def down
    execute 'ALTER TABLE targets DROP CONSTRAINT targets_pkey'
    drop_table :targets
  end
end
