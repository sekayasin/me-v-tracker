require "rails_helper"

RSpec.describe ProgramFeedbackPopupJob, type: :job do
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
  let!(:bootcamper) { create(:bootcamper) }
  let!(:nps_question) { create(:nps_question) }
  let!(:learner_program) do
    create(
      :learner_program,
      cycle_center: cycle_center,
      program_id: program.id,
      camper_id: bootcamper.camper_id
    )
  end

  let!(:schedule_feedback) do
    create(
      :schedule_feedback,
      nps_question_id: nps_question.nps_question_id,
      cycle_center_id: cycle_center.cycle_center_id,
      program_id: program.id
    )
  end

  context "feedback pop up" do
    before do
      next_pop_time = Time.parse(1.business_hours.ago.to_s)
      allow(Time).to receive(:now).and_return(next_pop_time)
    end

    it "creates a pop up for learners" do
      ProgramFeedbackPopupJob.perform_now

      scheduled_feedbacks = ScheduleFeedback.all.size
      expect(scheduled_feedbacks).to eq 1
    end
  end

  context "feedback pop up job" do
    subject(:job) { described_class.perform_later }

    it "pop up job queues" do
      expect { job }.
        to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it "default queue" do
      expect(subject.queue_name).to eq("default")
    end
  end
end
