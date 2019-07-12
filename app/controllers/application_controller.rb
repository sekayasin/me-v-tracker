require "jwt"

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :authentication
  before_action :redirect_non_andelan
  after_action :clear_xhr_flash

  helper_method :prettify_url

  include NotificationsControllerHelper
  include ApplicationControllerHelper
  rescue_from ActionController::UnknownFormat, with: :record_not_found
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def prettify_url(url)
    url.sub(%r{^https?\:\/\/(www.)?}, "")
  end

  def parse(data)
    JSON.parse(data)
  end

  private

  def authentication
    create_user_token
    save_respond_survey_url
    last_url_path = request.original_url.split("/").last
    cookies[:redirect_url] = set_redirect_url(last_url_path)
    if cookies["jwt-token"]
      decoded_token = validate_token(cookies["jwt-token"])
      if decoded_token
        authorize decoded_token
      else
        reset_session
        redirect_url = "
        #{request.protocol}#{request.host}:#{request.port}/login"
        logout_url = Figaro.env.logout_url + redirect_url
        redirect_to logout_url
      end
    else
      redirect_to "/login", notice: "unauthenticated"
    end
  end

  def save_respond_survey_url
    respond_url = request.original_url.split("/")
    last_url_path = respond_url.last
    if respond_url[3] == "surveys-v2" && respond_url[4] == "respond"
      home_url = "#{respond_url[0]}//#{respond_url[2]}"
      path = "#{respond_url[3]}/#{respond_url[4]}/#{last_url_path}"
      url = "#{home_url}/#{path}"
      session[:url] = url
    end
  end

  def set_redirect_url(last_url_path)
    if last_url_path == "logout"
      "#{request.protocol}#{request.host}:#{request.port}/"
    elsif last_url_path != "filter"
      request.original_url
    end
  end

  def authorize(decoded_token)
    user_email = decoded_token["UserInfo"]["email"]

    if (andelan? user_email) ||
       (authorized_learner? user_email)
      create_session decoded_token
    else
      redirect_to "/login", notice: "unauthorized"
    end
  end

  def andelan?(email)
    email.include?("andela.com")
  end

  def admin?(email)
    email["test-user-admin@andela.com"] ? true : false
  end

  def verify_admin?(decoded_token)
    if %w(staging development).include? Rails.env
      email = decoded_token["UserInfo"]["email"]
      return true if email == "test-user-admin@andela.com"
    end
    decoded_token["UserInfo"]["roles"].key?("VOF_Admin")
  end

  def create_session(decoded_token)
    user_info = {
      name: decoded_token["UserInfo"]["name"],
      admin: verify_admin?(decoded_token),
      picture: decoded_token["UserInfo"]["picture"],
      andelan: andelan?(decoded_token["UserInfo"]["email"]),
      lfa: andelan_lfa?(decoded_token["UserInfo"]["email"]),
      email: decoded_token["UserInfo"]["email"],
      learner: authorized_learner?(decoded_token["UserInfo"]["email"]),
      panelist: invited_panelist?(decoded_token["UserInfo"]["email"])
    }
    session[:current_user_info] = user_info
  end

  def authorized_learner?(learner_email)
    Bootcamper.find_by(email: learner_email).present?
  end

  def andelan_lfa?(andelan_email)
    facilitator_id = Facilitator.find_by(email: andelan_email)
    LearnerProgram.active.where(
      "(week_one_facilitator_id = :facilitator_id OR
        week_two_facilitator_id = :facilitator_id)",
      facilitator_id: facilitator_id
    ).present?
  end

  def invited_panelist?(andelan_email)
    panelist = Panelist.where(email: andelan_email).
               includes(%i(pitch)).pluck(:'pitches.demo_date')
    active_pitches = panelist.select { |demo_date| demo_date >= Date.today }
    panelist.present? && active_pitches.present?
  end

  def redirect_non_andelan
    if cookies["jwt-token"] && session[:url]
      redirect_to session[:url]
    elsif cookies["jwt-token"] && !session[:current_user_info][:andelan]
      redirect_to learner_path
    end
  end

  def redirect_non_admin_andelan
    if cookies["jwt-token"] &&
       !session[:current_user_info][:admin] &&
       !session[:current_user_info][:lfa]
      redirect_to analytics_path
    end
  end

  def redirect_unauthorized_learner
    if cookies["jwt-token"] && !session[:current_user_info][:learner]
      redirect_to index_path
    end
  end

  def record_not_found(error)
    Bugsnag.custom_notify(error)
    render json: error.message, status: 404, plain: "404 Not Found"
  end

  def clear_xhr_flash
    if request.xhr?
      flash.discard
    end
  end

  def create_notification(params)
    if validate_create(params).is_a?(Hash)
      { validate: validate_create(params) }
    else
      group = NotificationGroup.find_or_create_by(name: params[:group])
      message = NotificationsMessage.create!(
        priority: params[:priority], content: params[:content],
        notification_group_id: group.id
      )

      send_broadcast params, message
    end
  end

  def validate_token(token)
    JWT.decode(*jwt_params(token)).first
  rescue JWT::VerificationError, JWT::IncorrectAlgorithm,
         JWT::DecodeError, JWT::ExpiredSignature
    false
  end

  def jwt_params(token)
    return [token, nil, false] if Rails.env.test?

    decoded_token = JWT.decode(token, nil, false).first
    if authorized_learner?(decoded_token["UserInfo"]["email"])
      [token, OpenSSL::PKey::RSA.new(Figaro.env.learner_micro_public_key),
       true, algorithm: "RS256"]
    else
      [token, OpenSSL::PKey::RSA.new(Figaro.env.andela_micro_public_key),
       true, algorithm: "RS256"]
    end
  end

  def create_user_token
    if params[:token]
      cookies["jwt-token"] = {
        value: params[:token],
        expires: 1.week.from_now,
        domain: ".andela.com"
      }
    end
  end
end
