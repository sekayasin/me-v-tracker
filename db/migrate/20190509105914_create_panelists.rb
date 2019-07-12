class CreatePanelists < ActiveRecord::Migration[5.0]
  def change
    create_table :panelists do |t|
      t.references :pitch, foreign_key: true
      t.string :email
      t.string :accepted, default: false
      t.timestamps
    end
  end
end
