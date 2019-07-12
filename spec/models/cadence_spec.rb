require "rails_helper"

RSpec.describe Cadence, type: :model do
  describe "Cadence Associations" do
    it { is_expected.to have_many(:programs) }
  end
end
