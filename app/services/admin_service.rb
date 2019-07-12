require "httparty"

class AdminService
  def initialize
    limit = 30
    @all_admins = get_admins(limit)

    unless has_error?
      if @all_admins["total"] > limit
        @all_admins = get_admins(@all_admins["total"])
      end
    end
  end

  def admin_data
    @all_admins
  end

  def get_admins(limit)
    url = Figaro.env.user_microservice_api_url + "?limit=#{limit}"

    HTTParty.get(
      url,
      headers: { "api-token" => Figaro.env.user_microservice_api_token }
    )
  end

  def has_error?
    return true if @all_admins["error"]
  end
end
