class CreateLanguageStacks < ActiveRecord::Migration[5.0]
  def change
    create_table :language_stacks do |t|
      t.string :name
      t.boolean :dlc_stack_status

      t.timestamps
    end
  end
end
