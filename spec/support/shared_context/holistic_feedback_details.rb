RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "holistic feedback details", shared_context: :metadata do
  let(:user) { create :user }
  let(:holistic_feedback) { create :holistic_feedback }
  let(:bootcamper) { create :bootcamper_with_learner_program }
  let(:json) { JSON.parse(response.body) }

  let(:feedback_details) do
    {
      comment: holistic_feedback.comment,
      learner_program_id: holistic_feedback.learner_program.id,
      criterium_id: holistic_feedback.criterium.id
    }
  end
end

RSpec.configure do |rspec|
  rspec.include_context "holistic feedback details", include_shared: true
end
