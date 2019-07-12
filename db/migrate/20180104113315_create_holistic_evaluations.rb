class CreateHolisticEvaluations < ActiveRecord::Migration[5.0]
  def change
    unless table_exists?(:holistic_evaluations)
      create_table :holistic_evaluations do |t|
        t.integer :score
        t.text :comment
        t.references :learner_program, foreign_key: true
        t.references :criterium, foreign_key: true

        t.timestamps
      end
    end
  end
end
