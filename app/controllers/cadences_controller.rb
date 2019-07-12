class CadencesController < ApplicationController
  def index
    cadences = Cadence.all

    respond_to do |format|
      format.json { render json: cadences }
    end
  end
end
