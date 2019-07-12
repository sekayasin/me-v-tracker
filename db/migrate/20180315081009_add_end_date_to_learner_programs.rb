class AddEndDateToLearnerPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :learner_programs, :end_date, :date
  end
end
