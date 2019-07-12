class AlterScoreToFloat < ActiveRecord::Migration[5.0]
  def change
    change_column :scores, :score, :float
  end
end
