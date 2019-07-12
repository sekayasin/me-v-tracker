require "rails_helper"

RSpec.describe InviteLearnersJob do
  it "is called from bootcampers controller" do
    expect(
      BootcampersControllerHelper.const_get(:InviteLearnersJob)
    ).to eq InviteLearnersJob
  end

  it "matches with enqueued job" do
    user = [{ firstname: "user",
              lastname: "userlast", email: "user@site.com" }]
    ActiveJob::Base.queue_adapter = :test
    expect do
      InviteLearnersJob.perform_later(user)
    end.to have_enqueued_job(InviteLearnersJob).with(user)
  end
end
