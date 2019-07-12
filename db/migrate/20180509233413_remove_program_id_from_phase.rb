class RemoveProgramIdFromPhase < ActiveRecord::Migration[5.0]
    def up
      Rake::Task["db:populate_programphases_from_phases"].invoke
      remove_column :phases, :program_id, :integer
    end
  
    def down
      add_reference :phases, :program, foreign_key: true
      Rake::Task["db:populate_program_ids_in_phases"].invoke
    end
  end
