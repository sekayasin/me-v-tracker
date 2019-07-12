require "rails_helper"

RSpec.describe Center, type: :model do
  after(:all) do
    Center.delete_all
  end

  let(:valid_center) { create(:center) }

  it { is_expected.to have_many :cycles_centers }

  it "is valid with required attributes" do
    expect(valid_center.valid?).to be_truthy
  end

  it "is invalid without center name" do
    invalid_center = Center.new(attributes_for(:center, name: nil))

    expect(invalid_center.valid?).not_to be_truthy
  end
end
