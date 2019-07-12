RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "holistic evaluation details", shared_context: :metadata do
  let(:user) { create :user }
  let(:criterium) { create :criterium }
  let(:learner_program) { create :learner_program }
  let!(:holistic_evaluation) do
    create :holistic_evaluation, learner_program: learner_program
  end
  let!(:first_evaluation_average) do
    create :evaluation_average, holistic_average: 0, dev_framework_average: 1
  end
  let!(:second_evaluation_average) do
    create :evaluation_average, holistic_average: 0, dev_framework_average: 1
  end
end

RSpec.shared_context "get average details", shared_context: :metadata do
  let!(:holistic_evaluation) do
    create :holistic_evaluation,
           learner_program: learner_program,
           evaluation_average: first_evaluation_average
  end
  let!(:holistic_evaluation) do
    create :holistic_evaluation,
           learner_program: learner_program,
           evaluation_average: second_evaluation_average
  end
end

RSpec.shared_context "holistic evaluation data", shared_context: :metadata do
  let(:cycle) { create :cycle, cycle: 2 }
  let(:center) { create :center, name: "Lagos", country: "Nigeria" }
  let(:cycle_center) { create :cycle_center, cycle: cycle, center: center }
  let(:learner_program) { create :learner_program, cycle_center: cycle_center }
  let!(:dev_framework_criterium) do
    create(:criterium, belongs_to_dev_framework: true)
  end
  let(:criterium) { create :criterium }
  let(:evaluation_average) { create :evaluation_average }
  let(:data) do
    {
      learner_programs_id: learner_program.id,
      holistic_evaluation:
        {
          "0":
            {
              criterium_id: criterium.id,
              score: 2,
              comment: "Good"
            },
          "1":
            {
              criterium_id: dev_framework_criterium.id,
              score: 1,
              comment: "Nice"
            }
        }
    }
  end
end

RSpec.configure do |rspec|
  rspec.include_context "holistic evaluation details", include_shared: true
  rspec.include_context "get average details", include_shared: true
  rspec.include_context "holistic evaluation data", include_shared: true
end
