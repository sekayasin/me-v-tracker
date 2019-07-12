class AddTitleDescriptionColumnsToNpsQuestions < ActiveRecord::Migration[5.0]
  def change
    add_column :nps_questions, :title, :text
    add_column :nps_questions, :description, :text
    Rake::Task["db:add_title_description_to_nps_questions"].invoke
  end
end
