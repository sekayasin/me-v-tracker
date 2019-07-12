class AddEstimatedDurationToPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :programs, :estimated_duration, :string
  end
end
