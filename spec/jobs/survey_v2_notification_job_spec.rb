require "rails_helper"

RSpec.describe SurveyV2NotificationJob, type: :job do
  include ActiveJob::TestHelper

  let!(:center) { create(:center) }
  let!(:cycle) { create(:cycle) }
  let!(:program) { create(:program, name: "Andela Bootcamp version 1.5") }
  let!(:cycle_center) do
    create(
      :cycle_center,
      :start_today,
      cycle: cycle,
      center: center,
      program_id: program.id
    )
  end
  let(:new_survey) { create :new_survey }

  subject(:job) do
    described_class.
      perform_later(
        new_survey.id,
        new_survey.start_date.to_s,
        cycle_center.cycle_center_id
      )
  end

  it "queues the job as default" do
    expect { job }.to have_enqueued_job(described_class).
      with(
        new_survey.id,
        new_survey.start_date.to_s,
        cycle_center.cycle_center_id
      ).
      on_queue("default")
  end

  it "executes perform" do
    perform_enqueued_jobs { job }
  end
end
