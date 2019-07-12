class InviteLearnersJob < ApplicationJob
  queue_as :default

  def perform(users)
    HTTParty.post(
      Figaro.env.auth_url + "/users",
      body: { users: users,
              role: "vof-guest",
              access_token: Figaro.env.auth_access_token }.to_json,
      headers: { "Content-Type" => "application/json" },
      verify: false
    )
  rescue StandardError => e
    raise "An error has occured #{e}, while inviting #{users}"
  end
end
