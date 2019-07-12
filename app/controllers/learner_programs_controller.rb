class LearnerProgramsController < ApplicationController
  def get_existing_program
    render json: LearnerProgram.get_existing_program(
      params[:program_id],
      params[:city],
      params[:cycle]
    )
  end
end
