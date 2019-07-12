class ChangeEstimatedDurationToBeIntegerInPrograms < ActiveRecord::Migration[5.0]
  def up
    change_column :programs, :estimated_duration, 'integer USING CAST(estimated_duration AS integer)'
  end

  def down
    change_column :programs, :estimated_duration, :string
  end
end
