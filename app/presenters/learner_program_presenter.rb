class LearnerProgramPresenter < BasePresenter
  def registered
    @model[:created_at].to_date.strftime("%B %e, %Y")
  end
end
