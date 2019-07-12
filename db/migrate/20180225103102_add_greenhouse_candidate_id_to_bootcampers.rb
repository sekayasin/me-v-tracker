class AddGreenhouseCandidateIdToBootcampers < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :greenhouse_candidate_id, :string
  end
end
