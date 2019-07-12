require "rails_helper"

RSpec.describe OverdueSubmissionJob, type: :job do
  include ActiveJob::TestHelper

  let!(:center) { create(:center) }
  let!(:cycle) { create(:cycle) }
  let!(:program) { create(:program, name: "Andela Bootcamp") }
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
  let!(:learner_program) do
    create(
      :learner_program,
      cycle_center: cycle_center,
      program_id: program.id,
      camper_id: bootcamper.camper_id
    )
  end
  let!(:phase1) { create(:phase_assessments, name: "Phase 1") }
  let!(:programs_phase) do
    create(:programs_phase, phase_id: phase1.id, program_id: program.id)
  end
  let!(:phase2) { create(:phase_assessments, name: "Phase 2") }
  let!(:programs_phase2) do
    create(:programs_phase, phase_id: phase2.id, program_id: program.id)
  end

  context "overdue submission" do
    before do
      next_business_day = Time.parse(0.business_hours.from_now.to_s)
      allow(Time).to receive(:now).and_return(next_business_day)
    end

    it "creates notification for learners" do
      OverdueSubmissionJob.perform_now

      new_notification_count = Notification.all.size
      new_notification_group = NotificationGroup.all.size
      new_notification_message_count = NotificationsMessage.all.size

      expect(new_notification_group).to eq 1
      expect(new_notification_count).to eq 1
      expect(new_notification_message_count).to eq 1
    end
  end

  context "overdue submission job" do
    subject(:job) { described_class.perform_later }

    it "queues the job" do
      expect { job }.
        to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it "is in default queue" do
      expect(subject.queue_name).to eq("default")
    end
  end
end
