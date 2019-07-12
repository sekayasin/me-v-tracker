class AddPhaseLength < ActiveRecord::Migration[5.0]
  def change
    add_column :phases, :phase_duration, :integer
  end
end
