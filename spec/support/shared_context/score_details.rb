RSpec.configure do |rspec|
  # It causes the host group and examples to inherit metadata
  # from the shared context.
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "score details", shared_context: :metadata do
  let!(:phases) do
    [
      "Learning Clinic",
      "Bootcamp",
      "Project Assessment"
    ].map do |phase|
      create :phase, name: phase
    end
  end

  let!(:phase1_assessments) do
    [
      { name: "Growth Mindset", id: 1 },
      { name: "Seeks Feedback", id: 2 },
      { name: "Collaboration", id: 25 },
      { name: "Excellence", id: 21 }
    ]
  end

  let!(:phase2_assessments) do
    [
      { name: "Adaptability", id: 13 },
      { name: "Databases", id: 15 },
      { name: "Motivation and Commitment", id: 14 }
    ]
  end

  let!(:other_assessments) do
    [
      { name: "Version Control", id: 4 },
      { name: "Test-Driven Development", id: 6 },
      { name: "Project Management", id: 16 },
      { name: "Code Syntax Norms", id: 17 }
    ]
  end

  let!(:score_params) do
    {
      score: 1.0,
      assessment_id: phase1_assessments[0][:id],
      phase_id: phases[0].id,
      comments: "Good work"
    }
  end
end

RSpec.configure do |rspec|
  rspec.include_context "score details", include_shared: true
end
