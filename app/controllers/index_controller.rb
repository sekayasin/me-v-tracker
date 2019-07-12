class IndexController < ApplicationController
  require "assets/strip_whitespace"
  include IndexControllerHelper
  before_action :redirect_non_admin_andelan
  before_action :verify_program_id, only: %i(index sheet)

  def index
    @dashboard = IndexFacade.new(params)

    populate_dashboard

    respond_to do |format|
      format.js
      format.html
      format.json { render json: @dashboard }
    end
  end

  def admin?
    session[:current_user_info][:admin]
  end

  def panelist?
    session[:current_user_info][:panelist]
  end

  def sheet
    respond_to do |format|
      format.js
      format.html
      format.csv do
        render_learners_csv(
          program_id: params[:program_id],
          city: strip_whitespace(params[:city]),
          cycle: strip_whitespace(params[:cycle]),
          decision_one: strip_whitespace(params[:decision_one]),
          decision_two: strip_whitespace(params[:decision_two]),
          week_one_lfa: strip_whitespace(params[:week_one_lfa]),
          week_two_lfa: strip_whitespace(params[:week_two_lfa])
        )
      end
    end
  end

  def get_cities
    cities = Center.where(country: params[:country]).pluck("name")
    render json: cities
  end

  def get_latest_cycle
    cycle = Center.includes(:cycles_centers).
            where(name: params[:center].capitalize).
            first.cycles_centers.order(created_at: :asc).
            last.cycle.cycle
    render json: cycle
  end

  private

  def populate_dashboard
    set_page_size
    facilitator = session[:current_user_info][:lfa]
    if admin?
      populate_admin_dashboard
    elsif facilitator
      populate_lfa_dashboard
    end

    sort_option = get_sort_option
    @campers = sort_campers(@campers, params[:order], sort_option)
    @all_campers_count = @campers.count
    @maximum_evaluations = get_maximum_holistic_evaluations
    @campers = Kaminari.paginate_array(@campers).
               page(params[:page]).per(cookies[:size])
    IndexFacade.get_evaluation_averages(@campers)
  end

  def populate_lfa_dashboard
    program_id = params[:program_id]
    email = session[:current_user_info][:email]
    facilitator_data = Facilitator.find_by(email: email)
    query_string = @dashboard.query_params.to_s + @dashboard.search_params.to_s
    @campers = RedisService.get(
      "learnerspage:lfa_campers.#{query_string}.#{email}"
    )
    @campers = @campers ? @campers.map(&:symbolize_keys) : @campers
    unless @campers
      @campers = Bootcamper.arrange_learners(
        @dashboard.lfa_learners_data(facilitator_data, program_id)
      )
      RedisService.set(
        "learnerspage:lfa_campers.#{query_string}.#{email}", @campers
      )
    end
  end

  def populate_admin_dashboard
    query_string = @dashboard.query_params.to_s + @dashboard.search_params.to_s
    @campers = RedisService.get("learnerspage:campers.#{query_string}")
    @campers = @campers ? @campers.map(&:symbolize_keys) : @campers
    unless @campers
      @campers = Bootcamper.arrange_learners(@dashboard.table_data)
      RedisService.set("learnerspage:campers.#{query_string}", @campers)
    end
  end

  def set_page_size
    if cookies[:size].nil? || params[:size]
      cookies[:size] = params[:size] || 15
    end
  end

  def get_sort_option
    case params[:sort]
    when "name" then :first_name
    when "values" then :value_average
    when "output" then :output_average
    when "feedback" then :feedback_average
    when "overall_average" then :overall_average
    else :created_at
    end
  end

  def sort_campers(campers, sort_order, sort_option)
    if sort_order == "asc"
      campers.sort_by { |camper| camper[sort_option] }
    else
      campers.sort_by { |camper| camper[sort_option] }.reverse
    end
  end

  def verify_program_id
    unless params[:program_id]
      flash[:error] = "Please select an ALC program to proceed"
      redirect_to(index_path) && return
    end

    if params[:program_id].blank? || !Program.exists?(params[:program_id])
      redirect_to not_found_path
    end
  end

  def get_maximum_holistic_evaluations
    if !params[:program_id].blank? && Program.exists?(params[:program_id])
      Program.maximum_holistic_evaluations(params[:program_id])
    end
  end
end
