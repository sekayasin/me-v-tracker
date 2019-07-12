class AddScheduleDatesToSurveys < ActiveRecord::Migration[5.0]
  def change
    unless column_exists? :surveys, :start_date
      add_column :surveys, :start_date, :datetime
    end
    unless column_exists? :surveys, :end_date
      add_column :surveys, :end_date, :datetime
    end
  end
end
