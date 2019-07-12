class OverdueSubmissionJob < ApplicationJob
  include LearnersControllerHelper
  include ApplicationControllerHelper

  queue_as :default

  def perform(*_args)
    learner_programs = LearnerProgram.active

    learner_programs.each do |learner_program|
      program = learner_program.program
      phases = generate_phase_assessments(program, learner_program)

      end_of_day = Time.now.end_of_day
      time_range = ((end_of_day - 24.hour)..end_of_day)

      phases.each do |phase|
        output_due_time = Time.parse(phase[:due_date])
        next unless time_range.cover?(output_due_time)

        send_learner_notification(phase, learner_program)
      end
    end
  end

  private

  def send_learner_notification(phase, learner_program)
    phase[:assessments].each do |assessment|
      submitted = assessment[:submitted]
      requires_submission = assessment[:requires_submission]

      next unless !submitted && requires_submission

      email = learner_program.bootcamper[:email]

      notification_info = {
        recipient_emails: email,
        group: "Overdue Submissions",
        priority: "High",
        content: "Output on #{assessment[:name]} is due in 30 minutes"
      }

      save_learner_notification(notification_info)
    end
  end
end
