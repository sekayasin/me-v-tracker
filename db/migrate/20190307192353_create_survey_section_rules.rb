class CreateSurveySectionRules < ActiveRecord::Migration[5.0]
  def change
    create_table :survey_section_rules do |t|
      t.references :survey_section, :survey_option, foreign_key: true

      t.timestamps
    end
  end
end
