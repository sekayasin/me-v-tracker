require "rails_helper"

RSpec.describe TouristTour, type: :model do
  it { should belong_to(:tourist) }
  it { should belong_to(:tour) }
  it { should validate_presence_of(:tourist_email) }
  it { should validate_presence_of(:tour_id) }
  it { should validate_presence_of(:role) }
  it { should validate_inclusion_of(:role).in_array(%w[Admin]) }
end
