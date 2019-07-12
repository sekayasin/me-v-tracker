class RemoveTimestampDefaultFromDecisions < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:decisions, :created_at, nil)
    change_column_default(:decisions, :updated_at, nil)
  end
end
