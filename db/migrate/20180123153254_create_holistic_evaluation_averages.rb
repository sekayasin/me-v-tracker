class CreateHolisticEvaluationAverages < ActiveRecord::Migration[5.0]
  def change
    create_table :holistic_evaluation_averages do |t|
      t.float :average

      t.timestamps
    end
  end
end
