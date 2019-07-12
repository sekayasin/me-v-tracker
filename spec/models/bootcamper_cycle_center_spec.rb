require "rails_helper"

RSpec.describe BootcamperCycleCenter, type: :model do
  it { is_expected.to belong_to :bootcamper }
  it { is_expected.to belong_to :cycle_center }
end
