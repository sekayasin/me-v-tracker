class UpdateCriteriaDescriptions < ActiveRecord::Migration[5.0]
  def change
    Rake::Task["app:update_criteria_descriptions"].invoke
  end
end
