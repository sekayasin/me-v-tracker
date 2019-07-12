class FrameworksController < ApplicationController
  before_action :admin?, only: :update
  before_action :get_framework, only: %i(show update)

  def show
    render json: @framework
  end

  def update
    if framework_params[:description].blank?
      render json: { error: "Framework description cannot be blank!" }
    elsif @framework.blank?
      render json: { error: "Framework not found" }
    elsif @framework.update(framework_params)
      render json: { message: "Framework updated successfully" }
    else
      render json: { error: "Framework update unsuccessful" }
    end
  end

  private

  def admin?
    redirect_to content_management_path unless helpers.admin?
  end

  def get_framework
    @framework = Framework.find_by_id(params[:id])
  end

  def framework_params
    params.require(:framework).permit(:description)
  end
end
