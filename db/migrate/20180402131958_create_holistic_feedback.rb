class CreateHolisticFeedback < ActiveRecord::Migration[5.0]
  def change
    create_table :holistic_feedback do |t|
      t.text :comment
      t.references :learner_program, foreign_key: true
      t.references :criterium, foreign_key: true

      t.timestamps
    end
  end
end
