require "rails_helper"

RSpec.describe CompleteSurveyJob, type: :job do
  include ActiveJob::TestHelper
  let(:survey) { create :survey }

  subject(:job) do
    described_class.
      perform_later(survey.survey_id, survey.end_date.to_s)
  end

  it "queues the job as default" do
    ActiveJob::Base.queue_adapter = :test
    expect { job }.to have_enqueued_job(described_class).
      with(survey.survey_id, survey.end_date.to_s).
      on_queue("default")
  end

  it "executes perform" do
    perform_enqueued_jobs { job }
  end
end
