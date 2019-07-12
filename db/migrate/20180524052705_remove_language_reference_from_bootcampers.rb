class RemoveLanguageReferenceFromBootcampers < ActiveRecord::Migration[5.0]
  def change
    remove_reference :bootcampers, :language_stack, foreign_key: true
  end
end
