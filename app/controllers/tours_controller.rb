class ToursController < LearnersParentController
  include ToursControllerHelper
  before_action :get_tour_info

  def user_status
    if @tourist
      tourist_tour = TouristTour.find_by(
        tourist_email: @tourist.tourist_email,
        tour_id: @tour.id,
        role: @role
      )
    end

    render json: {
      has_toured: Rails.env.test? || tourist_tour.present?,
      role: @role,
      content: get_content(params[:page], @role)
    }
  end

  def create
    tourist_tour = TouristTour.find_or_initialize_by(
      tourist_email: @tourist.tourist_email,
      tour_id: @tour.id,
      role: @role
    )

    if tourist_tour.new_record? && tourist_tour.save
      render json: {
        message: "User tour entry successfully created",
        tourist_tour: tourist_tour
      }, status: 201
    end
  end

  private

  def get_tour_info
    @tour = get_tour params[:page]
    @tourist = get_tourist session[:current_user_info][:email]
    @role = get_tourist_role
  end
end
