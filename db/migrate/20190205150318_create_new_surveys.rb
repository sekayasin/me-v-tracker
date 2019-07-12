class CreateNewSurveys < ActiveRecord::Migration[5.0]
  def change
    create_table :new_surveys do |t|
      t.string :title
      t.text :description
      t.string :status

      t.timestamps
    end
  end
end
