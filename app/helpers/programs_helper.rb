module ProgramsHelper
  def get_program_description(program)
    if program.description.nil? || program.description == ""
      "N/A"
    else
      program.description
    end
  end

  def get_criterium_assessments(framework)
    assessments = []
    unless framework.criteria.empty?
      framework.criteria.first.framework_criteria.each do |framework_criterium|
        framework_criterium.assessments.each do |assessment|
          assessments.push(assessment)
        end
      end
    end
    assessments
  end

  def calculate_tracked_assessment(tracked_ouput, framework_details)
    result = (tracked_ouput.to_f / calculate_total_assessment(
      framework_details
    ).to_i) * 100

    result.round
  end

  def calculate_total_assessment(framework_details)
    total = 0
    framework_details.each do |framework|
      total += framework[:total_track]
    end

    total
  end
end
