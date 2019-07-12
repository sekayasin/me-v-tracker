class AddDaysToCadences < ActiveRecord::Migration[5.0]
  def change
    unless column_exists? :cadences, :days
      add_column :cadences, :days, :integer
    end

    Rake::Task["app:populate_cadence_days"].invoke
    Rake::Task["app:set_bootcamp_cadence_and_duration"].invoke
  end
end
