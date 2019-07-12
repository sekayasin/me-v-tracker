module ScoreControllerHelper
  def transform(phases)
    phases.map do |phase|
      random_phase_id = Faker::Number.between(1, 10)
      [random_phase_id, phase.name, phase.phase_duration]
    end
  end
end
