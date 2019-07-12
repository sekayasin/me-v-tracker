class CreateReflections < ActiveRecord::Migration[5.0]
  def change
    create_table :reflections do |t|
      t.string :comment
      t.integer :feedback_id

      t.timestamps
    end
    add_foreign_key :reflections, :feedback, column: :feedback_id, primary_key: :id
  end
end
