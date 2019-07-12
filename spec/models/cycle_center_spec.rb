require "rails_helper"

RSpec.describe CycleCenter, type: :model do
  after(:all) do
    CycleCenter.delete_all
  end

  let(:valid_cycle_center) { create(:cycle_center) }
  let(:inactive_cycle_center) do
    create(:cycle_center, start_date: Date.parse("2018-4-18"),
                          end_date: Date.parse("2018-4-25"))
  end
  let(:active_cycle_center) do
    create(:cycle_center, start_date: Date.today,
                          end_date: Date.today + 3.days)
  end
  let(:cycle_center_in_grace) do
    create(:cycle_center, start_date: 1.week.ago,
                          end_date: Date.yesterday)
  end

  let(:cycle_center_no_start_date) do
    build(:cycle_center, :empty_start_date)
  end

  it { is_expected.to belong_to :cycle }
  it { is_expected.to belong_to :center }
  it { is_expected.to belong_to :program }
  it { is_expected.to have_many :bootcamper_cycle_centers }
  it { should have_many(:bootcampers).through :bootcamper_cycle_centers }

  it "is valid with required attributes" do
    expect(valid_cycle_center.valid?).to be_truthy
  end

  it "is not valid without cycle id" do
    invalid_cycle_center = CycleCenter.new(
      attributes_for(:cycle_center, cycle_id: nil)
    )
    expect(invalid_cycle_center.valid?).not_to be_truthy
  end

  it "is not valid without center id" do
    invalid_cycle_center = CycleCenter.new(
      attributes_for(:cycle_center, center_id: nil)
    )
    expect(invalid_cycle_center.valid?).not_to be_truthy
  end

  it "is not valid without start date" do
    expect(cycle_center_no_start_date.valid?).not_to be_truthy
  end

  it "is not valid without end date" do
    cycle_center_nil_end_date = build(:cycle_center, :empty_end_date)
    expect(cycle_center_nil_end_date.valid?).not_to be_truthy
  end

  context "for non admin" do
    it "returns true if the bootcamp is ongoing" do
      boot_camp_ongoing = CycleCenter.active?(active_cycle_center.id)
      expect(boot_camp_ongoing).to be true
    end

    it "returns false if the bootcamp has ended" do
      boot_camp_ongoing = CycleCenter.active?(inactive_cycle_center.id)
      expect(boot_camp_ongoing).to be false
    end
  end

  context "for admin" do
    it "returns true if the bootcamp is ongoing" do
      boot_camp_ongoing = CycleCenter.active_for_admin?(active_cycle_center.id)
      expect(boot_camp_ongoing).to be true
    end

    it "returns true if bootcamp has ended but in grace period" do
      cycle_active = CycleCenter.active_for_admin?(cycle_center_in_grace.id)
      expect(cycle_active).to be true
    end

    it "returns false if bootcamp has ended and grace period has elapsed" do
      cycle_active = CycleCenter.active_for_admin?(inactive_cycle_center.id)
      expect(cycle_active).to be false
    end
  end
end
