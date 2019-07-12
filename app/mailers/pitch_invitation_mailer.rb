class PitchInvitationMailer < ApplicationMailer
  def invite_panelist_to_a_pitch(email, pitch_invite_link, pitch, pitch_cycle)
    attachments.inline["email-vof-logo.png"] =
      File.read("#{Rails.root}/app/assets/images/logos/email-vof-logo.png")
    @full_name = email.split("@")[0].sub(".", " ").titlecase
    @pitch_invite_link = pitch_invite_link
    @pitch_date = pitch.demo_date
    @cycle_name = pitch_cycle[0][:name]
    @cycle = pitch_cycle[0][:cycle]
    mail(to: email, subject: "Invitation to Pre-Fellowship Pitch")
  end

  def notify_rescheduled_pitch(email, pitch_date, center_name, cycle_number)
    attachments.inline["email-vof-logo.png"] =
      File.read("#{Rails.root}/app/assets/images/logos/email-vof-logo.png")
    @full_name = email.split("@")[0].sub(".", " ").titlecase
    @pitch_date = pitch_date
    @cycle_name = center_name
    @cycle = cycle_number
    mail(to: email, subject: "Pre-fellowship Pitch Rescheduling Update")
  end
end
