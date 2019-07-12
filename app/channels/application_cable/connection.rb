require "jwt"

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_cable_user

    def connect
      self.current_cable_user = find_verified_user
    end

    private

    def find_verified_user
      if request.cookies["jwt-token"]
        JWT.decode(request.cookies["jwt-token"], nil, false)[0]
      else
        reject_unauthorized_connection
      end
    end
  end
end
