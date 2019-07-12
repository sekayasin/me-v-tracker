class AddLanguageReferenceToBootcampers < ActiveRecord::Migration[5.0]
  def change
    add_reference :bootcampers, :language_stack, foreign_key: true
    add_reference :bootcampers, :proficiency, foreign_key: true
  end
end
