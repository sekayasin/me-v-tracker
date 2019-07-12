RSpec.configure do |rspec|
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "assessment context", shared_context: :metadata do
  let(:user) { create :user }
  let(:assessment_params) do
    attributes_for(
      :assessment,
      framework_criterium_id: create(:framework_criterium).id,
      metrics_attributes:
        Point.all.map do |point|
          attributes_for(:metric, point_id: point.id)
        end
    )
  end
  let(:point) { create_list(:point, 4) }
end

RSpec.configure do |rspec|
  rspec.include_context "assessment context", include_shared: true
end
