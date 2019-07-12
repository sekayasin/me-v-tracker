require "rails_helper"

RSpec.describe SurveySectionRuleSerializer, type: :serializer do
  let(:admin) { create(:user, :admin) }
  let!(:new_survey) { create(:new_survey) }
  let(:section_links) do
    {
      "section 2": { survey_section_id: 1, survey_option_id: 1 }
    }
  end

  subject { described_class }

  it "checks that the response is not empty" do
    response = subject.new(section_links)
    expect(response).not_to be_nil
  end

  it "return a hash" do
    response = subject.new(section_links)
    expect(response).to be_a Object
  end
end
