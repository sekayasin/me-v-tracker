class CreateAssessmentOutputSubmissions < ActiveRecord::Migration[5.0]
  def change
    create_table :assessment_output_submissions do |t|
      t.integer :position
      t.string :title
      t.integer :day
      t.string :file_type
      t.references :assessment
      t.timestamps
    end
  end
end
