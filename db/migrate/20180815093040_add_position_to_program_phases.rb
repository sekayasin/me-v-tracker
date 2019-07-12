class AddPositionToProgramPhases < ActiveRecord::Migration[5.0]
  def change
    add_column :programs_phases, :position, :integer
    Rake::Task["app:add_position_values_to_programs_phases"].invoke
    remove_column :phases, :position
  end
end
