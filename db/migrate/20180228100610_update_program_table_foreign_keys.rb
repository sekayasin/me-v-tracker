class UpdateProgramTableForeignKeys < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :phases, :programs
    remove_foreign_key :dlc_stacks, :programs
    remove_foreign_key :learner_programs, :programs

    add_foreign_key :phases, :programs, on_delete: :cascade
    add_foreign_key :dlc_stacks, :programs, on_delete: :cascade
    add_foreign_key :learner_programs, :programs, on_delete: :cascade
  end
end
