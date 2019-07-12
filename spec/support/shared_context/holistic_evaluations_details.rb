RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "holistic evaluations details", share_context: :metadata do
  let(:cadence) { create :cadence, days: 1 }
  let(:program) do
    create(:program, estimated_duration: 2, cadence_id: cadence.id)
  end
  let(:learner_program) { create :learner_program, program_id: program.id }
  let(:first_criterium) { create :criterium }
  let(:second_criterium) { create :criterium }
  let(:phase) { create :phase }
  let!(:programs_phase) do
    create(:programs_phase, program_id: program.id, phase_id: phase.id)
  end
  let!(:first_assessment) do
    create(:assessment, phases: [phase], criterium: first_criterium)
  end
  let!(:second_assessment) do
    create(:assessment, phases: [phase], criterium: second_criterium)
  end
  let(:evaluation_average) { create :evaluation_average, holistic_average: 1.5 }
  let!(:holistic_evaluations) do
    [
      FactoryBot.create_custom_evaluation(
        1,
        learner_program,
        first_criterium,
        evaluation_average.id
      ),
      FactoryBot.create_custom_evaluation(
        2,
        learner_program,
        second_criterium,
        evaluation_average.id
      ),
      FactoryBot.create_custom_evaluation(
        2,
        learner_program,
        first_criterium,
        nil
      ),
      FactoryBot.create_custom_evaluation(
        1,
        learner_program,
        second_criterium,
        nil
      )
    ]
  end

  let(:evaluations) do
    HolisticEvaluation.get_evaluations(learner_program.id)
  end

  let(:holistic_evaluation_details) do
    {
      Quality: [0, 0, 0],
      Quantity: [2, 2, 2],
      Integration: [-1, 2, 2]
    }
  end

  let(:evaluation_groups) do
    split_holistic_evaluation(holistic_evaluations)
  end
end

RSpec.configure do |rspec|
  rspec.include_context "holistic evaluations details", include_shared: true
end
