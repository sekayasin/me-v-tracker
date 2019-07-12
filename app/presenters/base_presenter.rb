class BasePresenter < SimpleDelegator
  def initialize(model, view)
    @model = model
    @view = view
    super @model
  end
end
