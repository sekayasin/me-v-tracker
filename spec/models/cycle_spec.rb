require "rails_helper"

RSpec.describe Cycle, type: :model do
  after(:all) do
    Cycle.delete_all
  end

  let(:valid_cycle) { create(:cycle) }

  it { is_expected.to have_many :cycles_centers }
  it { is_expected.to validate_uniqueness_of(:cycle) }

  it "is valid with required attributes" do
    expect(valid_cycle.valid?).to be_truthy
  end

  it "is invalid without cycle number" do
    cycle = Cycle.new(attributes_for(:cycle, cycle: nil))

    expect(cycle.valid?).not_to be_truthy
  end
end
