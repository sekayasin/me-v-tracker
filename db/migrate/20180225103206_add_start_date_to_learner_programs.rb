class AddStartDateToLearnerPrograms < ActiveRecord::Migration[5.0]
  def change
    add_column :learner_programs, :start_date, :date
  end
end
