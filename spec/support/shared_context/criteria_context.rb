RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "criteria context", shared_context: :metadata do
  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }
  let(:program) { Program.first }
  let(:framework_criteria) { create :framework_criterium }
end

RSpec.shared_context "program criteria context", shared_context: :metadata do
  let!(:program) { create :program }
  let!(:phase) { create :phase }
  let!(:programs_phase) do
    create(:programs_phase, program_id: program.id, phase_id: phase.id)
  end
  let!(:criterium) { create :criterium, name: "Understanding" }
  let!(:assessment) do
    create(
      :assessment,
      phases: [phase],
      criterium: criterium,
      name: "Programming"
    )
  end
end

RSpec.configure do |rspec|
  rspec.include_context "criteria context", include_shared: true
  rspec.include_context "program criteria context", include_shared: true
end
