class CreateFeedback < ActiveRecord::Migration[5.0]
  def change
    create_table :feedback do |t|
      t.references :learner_program, foreign_key: true
      t.references :phase, foreign_key: true, on_delete: :cascade
      t.references :assessment, foreign_key: true
      t.references :impression, foreign_key: true
      t.text :comment
      t.text :reflection

      t.timestamps
    end
  end
end
