require "rails_helper"

RSpec.describe ApplicationMailer, type: :mailer do
  describe "notify" do
    let(:mail) { ApplicationMailer.new }

    it "renders mailer template" do
      expect(mail.action_has_layout?).to be true
    end
  end
end
