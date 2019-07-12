class CreateScores < ActiveRecord::Migration[5.0]
  def change
    create_table :scores do |t|
      t.integer :score
      t.string  :week
      t.text    :comments
      t.string  :camper_id
      t.references :assessment, foreign_key: true
      t.references :facilitator, foreign_key: true
      t.references :phase, foreign_key: true
      t.timestamps
    end

    add_foreign_key :scores, :bootcampers, column: :camper_id, primary_key: :camper_id
  end
end
