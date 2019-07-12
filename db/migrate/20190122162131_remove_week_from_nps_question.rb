class RemoveWeekFromNpsQuestion < ActiveRecord::Migration[5.0]
  def change
    remove_column :nps_questions, :week, :integer
  end
end
