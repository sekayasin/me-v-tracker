class UpdateExistingScoresFrom012To123 < ActiveRecord::Migration[5.0]
  def change
    [2, 1, 0].each do |score|
      Score.where(score: score).update_all(score: score + 1)
    end
  end
end
