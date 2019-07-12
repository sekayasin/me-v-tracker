module IndexHelper
  def pagination_metadata(current_page, page_size, page_count, total_count)
    start_count = page_size.to_i * (current_page - 1)
    count_message = "#{start_count + page_count} of #{total_count} entries"
    result = total_count.zero? ? start_count : start_count + 1

    "Showing #{result} to " + count_message
  end

  def get_lfas(city, cycle)
    lfas = RedisService.get("learnerspage:lfas_week_1.#{city}.#{cycle}")
    unless lfas
      lfas = LearnerProgram.lfas(city, cycle)
      RedisService.set("learnerspage:lfas_week_1.#{city}.#{cycle}", lfas)
    end
    get_lfas_info(lfas)
  end

  def page_rows
    %w(15 30 45 60)
  end

  def decision_comments(comment)
    comment&.empty? ? "No comment" : comment
  end

  def filter_selected?(param_value, filter_data)
    if param_value.is_a?(Array)
      param_value.include? filter_data
    else
      param_value == filter_data
    end
  end

  def get_lfas_info(lfas)
    lfas = [] if lfas.any?(&:nil?)
    lfas.map do |lfa|
      email = lfa["email"]
      next if email.blank?

      name = email.split("@")[0].split(".")
      {
        name: name.each(&:capitalize!).join(" "),
        email: email
      }
    end.compact
  end

  def get_total_assessed(learner_program_id)
    Score.total_assessed(learner_program_id)
  end

  def get_total_assessments(program_id)
    Assessment.get_total_assessments(program_id)
  end

  def get_total_percentage(total_assessed, total_assessments)
    total_assessed = Float(total_assessed)
    total_assessments = Float(total_assessments)

    if total_assessments.zero?
      0
    else
      ((total_assessed * 100) / total_assessments).round
    end
  end

  def get_progress_status(total_percentage)
    if total_percentage.positive? && total_percentage < 50
      "below-average"
    elsif total_percentage >= 50 && total_percentage <= 99
      "average-and-above"
    else
      "completed"
    end
  end

  def resized_profile_image
    session[:current_user_info][:picture]
  end

  def get_received_holistic_evaluations(learner_program_id)
    learner_program = LearnerProgram.find_by(id: learner_program_id)

    learner_program.nil? ? 0 : learner_program.holistic_evaluations_received
  end

  def language_stacks
    LanguageStack.all
  end
end
