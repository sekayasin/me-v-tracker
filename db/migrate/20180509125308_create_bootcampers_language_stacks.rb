class CreateBootcampersLanguageStacks < ActiveRecord::Migration[5.0]
  def change
    create_table :bootcampers_language_stacks, :id => false do |t|
      t.string :camper_id
      t.references :language_stack, foreign_key: true
    end

    add_foreign_key :bootcampers_language_stacks, :bootcampers, column: :camper_id,
                   primary_key: :camper_id
    add_index :bootcampers_language_stacks, :camper_id

    Rake::Task["db:migrate_language_stacks_to_bootcampers_language_stacks"].invoke
  end
end
