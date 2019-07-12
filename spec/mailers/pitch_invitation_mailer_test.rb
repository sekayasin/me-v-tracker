require "test_helper"

class PitchInvitationMailerTest < ActionMailer::TestCase
  test "pitch_invitation" do
    mail = PitchInvitationMailer.invite_panelist_to_a_pitch
    assert_equal ["me@example.com"], mail.from
    assert_equal ["friend@example.org"], mail.to
    assert_equal "Invitation to Pre-Fellowship Pitch", mail.subject
    assert_match "Hi", mail.body.encoded
  end
end
