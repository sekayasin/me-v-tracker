class AddProgramReferencesToPhases < ActiveRecord::Migration[5.0]
  def change
    add_reference :phases, :program, foreign_key:true 
  end
end
