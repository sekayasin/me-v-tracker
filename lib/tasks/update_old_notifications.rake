require "time"

def get_active_program_rake(lps, date)
  lps.each do |lp|
    cc = lp.cycle_center
    next unless cc.start_date && cc.end_date

    range = cc.start_date.to_time..cc.end_date.to_time
    break lp if range.include? date.to_time
  end
end

def get_current_phase_rake(start_date, phases, notf_date)
  phase_duration = 0
  phases.each do |phase|
    date = phase_duration.business_days.after(start_date)
    range = (date.to_time)..
      phase.phase_duration.business_days.after(date).end_of_day.to_time
    break phase if range.include? notf_date.to_time

    phase_duration += phase.phase_duration || 0
  end
end

namespace :app do
  desc "Updates old learner notifications to have links"
  task update_old_notifications: :environment do
    old_notifications = NotificationsMessage.includes(:notification).
                        # rubocop:disable LineLength
                        where(
                          "content \
                          LIKE 'Hello! you have received a feedback from your LFA on <strong>%'"
                        )
    # rubocop:enable LineLength

    old_notifications.each do |n|
      as = n.content.scan(%r/<strong>(.*)<\/strong> output/)[0][0]
      next unless as

      assessment = Assessment.includes(:phases).find_by(name: as)
      next unless n.notification.size == 1

      b = Bootcamper.find_by(email: n.notification.first.recipient_email)
      next unless b

      lp = get_active_program_rake(LearnerProgram.
        where(camper_id: b.id), n.created_at)
      next unless lp

      phase = get_current_phase_rake(lp.cycle_center.start_date,
                                     lp.program.phases, n.created_at)
      next unless phase && assessment.phases.include?(phase)

      n.update!(
        content: "Hello! you have received
        a feedback from your LFA on
        <a class='notification-link'>
          <strong phase-id='#{phase.id}'
            assessment-id='#{assessment.id}'> #{assessment.name}
          </strong>
        </a>
        output"
      )
    end
  end
end
