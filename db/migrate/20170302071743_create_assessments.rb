class CreateAssessments < ActiveRecord::Migration[5.0]
  def change
    create_table :assessments do |t|
      t.string     :name
      t.references :criterium, foreign_key: true
      t.references :phase, foreign_key: true
      t.timestamps
    end
  end
end
