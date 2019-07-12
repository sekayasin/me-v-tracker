require "rails_helper"

RSpec.describe Tour, type: :model do
  it { should have_many(:tourist_tours) }
  it { should validate_presence_of(:name) }
end
