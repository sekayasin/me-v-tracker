require "rails_helper"

RSpec.describe Tourist, type: :model do
  it { should have_many(:tourist_tours) }
  it { should validate_presence_of(:tourist_email) }
end
