class CreateLearnersPitches < ActiveRecord::Migration[5.0]
  def change
    create_table :learners_pitches do |t|
      t.references :pitch, foreign_key: true
      t.string   "camper_id"
      t.timestamps
    end

    add_foreign_key :learners_pitches, :bootcampers, column: :camper_id, primary_key: :camper_id
  end
end
