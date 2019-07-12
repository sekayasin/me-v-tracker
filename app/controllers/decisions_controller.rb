class DecisionsController < ApplicationController
  include DecisionsControllerHelper

  def get_history
    learner_program_id = params[:learner_program_id]
    decision_history = Decision.get_decisions(learner_program_id)
    processed_history = prepare_decision_history(decision_history)
    render json: processed_history
  end

  def get_decision_reason
    decision_reason = DecisionStatus.get_reasons(params[:status])

    render json: decision_reason
  end

  def save_decision
    return unless helpers.admin?

    decisions = params[:decisions]
    decision_reason_ids = DecisionReason.get_ids(decisions[:reasons])

    decision = Decision.save_decision(
      decisions[:learner_program_id],
      decisions[:stage],
      decision_reason_ids,
      decisions[:comment]
    )

    if decision
      render json: { message: "Decision updated successfully" }
    else
      render json: { errors: "Decision update was unsuccessful" }
    end
  end
end
