class CreateTourists < ActiveRecord::Migration[5.0]
  def change
    create_table :tourists, id: false do |t|
      t.string :tourist_email, primary_key: true

      t.timestamps
    end
  end
end
