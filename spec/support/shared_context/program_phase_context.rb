RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "program phase context", shared_context: :metadata do
  let!(:program) { create(:program, name: "Andela ALC") }
  let!(:phase) { create(:phase, name: "Bootcamp") }
  let(:criterium) { create :criterium, name: "Understanding" }
  let!(:programs_phase) do
    create(:programs_phase, program_id: program.id, phase_id: phase.id)
  end
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
  rspec.include_context "program phase context", include_shared: true
end
