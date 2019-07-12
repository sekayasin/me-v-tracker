require "rails_helper"

RSpec.describe Panelist, type: :model do
  describe "Association" do
    it { should belong_to(:pitch) }
    it { should have_many(:ratings) }
  end
  describe "Validations" do
    it { validate_presence_of(:pitch_id) }
    it { validate_presence_of(:email) }
    it { validate_presence_of(:accepted) }
  end
end
