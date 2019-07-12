class UpdateFeedbackTable < ActiveRecord::Migration[5.0]
  def change
    remove_column :feedback, :reflection, :string
  end
end
