class NoAccessController < ApplicationController
  protect_from_forgery prepend: true

  def index; end
end
