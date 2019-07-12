class AddUniqueIndexToOutputLinks < ActiveRecord::Migration[5.0]
  def change
    add_index :output_links, %i(camper_id assessment_id phase_id), unique: true
  end
end
