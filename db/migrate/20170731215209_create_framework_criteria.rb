class CreateFrameworkCriteria < ActiveRecord::Migration[5.0]
  def change
    create_table :framework_criteria do |t|
      t.references :criterium, foreign_key: true
      t.references :framework, foreign_key: true

      t.timestamps
    end
  end
end
