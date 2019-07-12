require "rails_helper"
require "spec_helper"
require "helpers/learner_bio_helper"

describe "Learners notification test" do
  include LearnerBioHelper
  before :all do
    set_up
  end

  after :all do
    tear_down
  end

  before :each do
    stub_non_andelan_bootcamper(@bootcamper)
    stub_current_session_bootcamper(@bootcamper)
    visit("/learner")
    sleep 1
    find("a.notifications-trigger").click
  end
end
