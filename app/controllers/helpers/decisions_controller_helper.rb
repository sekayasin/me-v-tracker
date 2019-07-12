module DecisionsControllerHelper
  def prepare_decision_history(decisions)
    decision_history = []
    stages = decisions.map(&:decision_stage).uniq.reverse
    stages.each do |stage|
      stage_decisions = decisions.select do |decision|
        decision.decision_stage == stage
      end

      next unless decision_valid?(stage_decisions.last)

      decision_history << format_decision_details(stage_decisions)
    end

    decision_history
  end

  def get_decision_status(decision)
    stage = decision.decision_stage
    if stage == 1
      decision.learner_program.decision_one
    elsif stage == 2
      decision.learner_program.decision_two
    end
  end

  def decision_valid?(decision)
    return false if decision.blank?

    decision_status = get_decision_status(decision) || ""

    if ["In Progress", "Not Applicable", ""].include? decision_status
      false
    else
      true
    end
  end

  def list_decision_reasons(decisions)
    decisions.map { |decision| decision.decision_reason.reason }.uniq
  end

  def format_decision_details(decisions)
    last_decision = decisions.last
    lfa_email = get_lfa_email(last_decision)
    lfa_name = get_lfa_name(lfa_email)
    decision_status = get_decision_status(last_decision)
    reasons_list = list_decision_reasons(decisions)

    {
      created_at: {
        date: last_decision.created_at.strftime("%B %e, %Y"),
        time: last_decision.created_at.strftime("%H:%M:%S GMT")
      },
      stage: last_decision.decision_stage,
      multiple_reasons: reasons_list.length > 1,
      details: {
        LFA: lfa_name,
        Decision: decision_status,
        Reasons: reasons_list.join(", "),
        Comment: last_decision.comment || "N/A"
      }
    }
  end

  def get_lfa_email(decision)
    if decision.decision_stage == 1
      decision&.learner_program&.week_one_facilitator&.email
    elsif decision.decision_stage == 2
      decision&.learner_program&.week_two_facilitator&.email
    end
  end

  def get_lfa_name(email)
    if email.blank?
      ""
    else
      lfa_name = email.split("@")[0].split(".")
      capitalize_lfa_name(lfa_name)
    end
  end

  def capitalize_lfa_name(names)
    capitalized_names = names.map(&:capitalize)
    capitalized_names.join(" ")
  end
end
