class AddProgramReferenceToBootcamper < ActiveRecord::Migration[5.0]
  def change
    add_reference :bootcampers, :program, foreign_key: true
  end
end
