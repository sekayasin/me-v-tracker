module AddFacilitatorHelper
  def create_seed_data
    @center = create(:center, name: "Lagos", country: "Nigeria")
    @cycle = create(:cycle)
    @camper = create(:bootcamper)
    @cycle_center = create(
      :cycle_center,
      center_id: @center[:center_id],
      cycle_id: @cycle[:cycle_id],
      end_date: Date.tomorrow
    )
    @learner_program = create(
      :learner_program,
      camper_id: @camper[:camper_id],
      cycle_center_id: @cycle_center[:cycle_center_id],
      decision_one: "Advanced"
    )
  end

  def clear_seed_data
    @learner_program.destroy
    @cycle_center.destroy
    @camper.destroy
    @center.destroy
    @cycle.destroy
  end
end
