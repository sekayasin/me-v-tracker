class CreateDlcStacks < ActiveRecord::Migration[5.0]
  def change
    create_table :dlc_stacks do |t|
      t.references :program, foreign_key: true
      t.references :language_stack, foreign_key: true

      t.timestamps
    end
  end
end
