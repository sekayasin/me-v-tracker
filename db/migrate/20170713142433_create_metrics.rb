class CreateMetrics < ActiveRecord::Migration[5.0]
  def change
    create_table :metrics do |t|
      t.text :description
      t.references :point, foreign_key: true
      t.references :assessment, foreign_key: true
    end
  end
end
