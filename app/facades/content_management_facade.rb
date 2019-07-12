class ContentManagementFacade
  def initialize
    @frameworks = Framework.order("name DESC").includes(
      criteria: {
        framework_criteria: :assessments
      }
    ).all
    @framework = Framework.new
    @criterium = Criterium.new
    @assessment = Assessment.new
    @programs = Program.all
    @program = Program.new
    @languages = LanguageStack.all.pluck(:name, :id)
    Point.all.each { |point| @assessment.metrics.build(point: point) }
  end

  def get_content
    {
      frameworks: @frameworks,
      framework: @framework,
      criterium: @criterium,
      assessment: @assessment,
      programs: @programs,
      program: @program,
      languages: @languages
    }
  end
end
