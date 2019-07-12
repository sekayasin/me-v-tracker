class AddOutputSumissionIdToFeedback < ActiveRecord::Migration[5.0]
  def change
    add_column :feedback, :output_submissions_id, :integer
  end
end
