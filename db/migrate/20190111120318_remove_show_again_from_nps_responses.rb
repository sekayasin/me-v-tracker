class RemoveShowAgainFromNpsResponses < ActiveRecord::Migration[5.0]
    def change
      remove_column :nps_responses, :show_again, :boolean
    end
  end