class SessionsController < ApplicationController
  skip_before_action :authentication, only: :login
  skip_before_action :redirect_non_andelan

  def login
    if session[:current_user_info] && cookies["jwt-token"] || params[:token]
      redirect_to "/"
    else
      home_url = "#{request.protocol}#{request.host}:#{request.port}/"
      redirect_url = cookies[:redirect_url] || home_url
      @login_url = Figaro.env.auth_url + "/users/login"
      @oauth_url = Figaro.env.login_url + redirect_url
      @forgot_url = Figaro.env.auth_url + "/invites"
      cookies[:redirect_url] = home_url
    end
  end

  def logout
    reset_session
    cookies.delete :size
    redirect_url = "#{request.protocol}#{request.host}:#{request.port}/login"
    logout_url = Figaro.env.logout_url + redirect_url
    redirect_to logout_url
  end
end
