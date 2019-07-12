class CreateRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :ratings do |t|
      t.references :learners_pitch, foreign_key: true
      t.references :panelist, foreign_key: true
      t.integer :ui_ux
      t.integer :api_functionality
      t.integer :error_handling
      t.integer :project_understanding
      t.integer :presentational_skill
      t.string :decision
      t.text :comment
      t.timestamps
    end

  end
end
