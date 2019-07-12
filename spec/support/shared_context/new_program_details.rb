RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "new program details", shared_context: :metadata do
  let(:user) { create :user }
  let(:json) { JSON.parse(response.body) }
  let(:params) do
    {
      program: {
        name: "Bootcamp V5",
        description: "A new Program",
        phases: ["first phase", "second phase"]
      }
    }
  end
  let(:clone_params) do
    {
      program: {
        program_id: 1,
        name: "Cloned Program",
        description: "fellow selection process"
      }
    }
  end

  before do
    stub_current_user(:user)
    controller.stub(:admin?)
  end
end

RSpec.configure do |rspec|
  rspec.include_context "new program details", include_shared: true
end
