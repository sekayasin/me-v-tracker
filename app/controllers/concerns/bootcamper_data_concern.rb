module BootcamperDataConcern
  extend ActiveSupport::Concern

  private

  def bootcamper_program(query = [])
    LearnerProgram.
      includes(query).
      where(bootcampers: {
              email: session[:current_user_info][:email]
            })
  end
end
