class CreateOutputLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :output_links do |t|
      t.string :link
      t.string :camper_id
      t.references :assessment, foreign_key: true
      t.references :phase, foreign_key: true

      t.timestamps
    end

    add_foreign_key :output_links, :bootcampers, column: :camper_id, primary_key: :camper_id
  end
end
