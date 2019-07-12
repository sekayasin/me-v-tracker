class AddPerformanceAndOutputTargetToTargets < ActiveRecord::Migration[5.0]
  def up
    remove_timestamps :targets
    rename_column :targets, :value, :performance_target
    add_column :targets, :output_target, :decimal, default: 0.0
  end

  def down
    time_stamp = DateTime.now

    add_timestamps :targets, null: true
    rename_column :targets, :performance_target, :value
    Target.update_all(value: 0, created_at: time_stamp, updated_at: time_stamp)
    remove_column :targets, :output_target
    change_column_null :targets, :created_at, false
    change_column_null :targets, :updated_at, false
  end
end
