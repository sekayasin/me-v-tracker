require "json"

class ScoringGuideService
  def initialize
    @feedback_guide = read_file("feedback_score_metrics.json")
    @values_alignment_guide = read_file("values_alignment_score_metrics.json")
    @output_quality_guide = read_file("output_quality_score_metrics.json")
    @assessments_map = read_file("assessment_framework_criteria.json")
  end

  def read_file(file_name)
    base_path = Rails.root.join("config", "json_data")
    file = File.read(base_path.join(file_name).to_s)
    JSON.parse file
  end

  def get_guide(phase, criterium, assessment)
    if criterium == "Output Quality"
      @output_quality_guide[assessment]
    end

    if criterium == "Feedback"
      @feedback_guide[assessment]
    end

    if criterium == "Values Alignment" && phase.include?("Home Session")
      @values_alignment_guide["Home Sessions"][assessment]
    else
      @values_alignment_guide[phase][assessment]
    end
  end

  def get_criterion_guide(criterion)
    scoring_guide_hash = {
      "Output Quality" => @output_quality_guide,
      "Feedback" => @feedback_guide,
      "Values Alignment" => @values_alignment_guide
    }
    scoring_guide_hash[criterion]
  end

  def get_assessments(criterion, framework)
    criterion_assessements = @assessments_map[criterion].nil?
    @assessments_map[criterion][framework] unless criterion_assessements
  end
end
