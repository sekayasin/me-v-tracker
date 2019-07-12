class AddEditResponseToNewSurveys < ActiveRecord::Migration[5.0]
  def change
    add_column :new_surveys, :edit_response, :boolean
  end
end
