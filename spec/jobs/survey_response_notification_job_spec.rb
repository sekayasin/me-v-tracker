require "rails_helper"

RSpec.describe SurveyResponseNotificationJob, type: :job do
  include ActiveJob::TestHelper

  describe "Perform Job" do
    it "successfully queue job" do
      expect do
        SurveyResponseNotificationJob.perform_later
      end.to have_enqueued_job
    end

    it "use a default queue" do
      expect(SurveyResponseNotificationJob.new.queue_name).to eq("default")
    end
  end
end
