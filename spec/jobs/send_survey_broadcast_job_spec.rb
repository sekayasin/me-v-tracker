require "rails_helper"
require "spec_helper"
require "helpers/send_survey_broadcast_helper_spec"

RSpec.describe SendSurveyBroadcastJob, skip: true do
  include SendSurveyBroadcastHelpers
  before :all do
    set_up
  end

  context "send broadcast job" do
    subject(:job) do
      SendSurveyBroadcastJob.perform_later(@survey_pivot.survey, "update")
    end

    it "is called from survey controller" do
      expect(
        SurveysController.const_get(:SendSurveyBroadcastJob)
      ).to eq SendSurveyBroadcastJob
    end

    it "queues the job" do
      ActiveJob::Base.queue_adapter = :test
      expect { job }.to have_enqueued_job(described_class)
    end

    it "increase the size of enqueued jobs" do
      ActiveJob::Base.queue_adapter = :test
      expect { job }.
        to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it "is in default queue" do
      expect(subject.queue_name).to eq("default")
    end
  end

  after do
    tear_down
  end
end
