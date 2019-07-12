class LearnersDashboard.App
  constructor: ->
    @learnersDashboardApi = new LearnersDashboard.API()
    @learnersDashboardUI = new LearnersDashboard.UI()
    @decisionHistoryApi = new DecisionHistory.Api()

  start: =>
    @learnersDashboardUI.changeLearnerStatus(
      $('.decision-item'),
      @learnersDashboardApi.getDecisionReason,
      @decisionHistoryApi.getDecisionHistory
    )
    @learnersDashboardUI.changeDecisionStatus(@learnersDashboardApi.getDecisionReason, @decisionHistoryApi.getDecisionHistory)
    @learnersDashboardUI.handleOnClickSaveDecision(@saveLearnersDecisionDetails)
    @learnersDashboardUI.clickColumnFilterList()
    @learnersDashboardUI.closeDecisionAndLFADropdownsByIcon()
    @learnersDashboardUI.downloadCSV()
    @learnersDashboardUI.handleCloseDecisionUpdateModal()

    @learnersDashboardUI.onPageLoad()
    @learnersDashboardUI.onPageResize()
    @learnersDashboardUI.onTableScroll()
  
  saveLearnersDecisionDetails: (
    learnerDecisionStatus,
    status,
    learnerProgramId,
    decisionData,
    decisionStatusElementId
  ) =>
    self = @
    if learnerDecisionStatus != "In Progress"and Boolean(learnerDecisionStatus)
      self.learnersDashboardUI.clearErrorText("#decision-status-error")
      if !decisionData.decisions.reasons.includes('Select Reasons')
        self.learnersDashboardUI.clearErrorText("#decision-reason-error")
        self.learnersDashboardApi.setDecisionStatus(status, learnerProgramId).
          then () =>
            self.learnersDashboardApi.saveDecision(decisionData).
              then (saveResponse) =>
                if saveResponse
                  # update decision status on the learners table appropriately
                  $("##{decisionStatusElementId}").val(learnerDecisionStatus)

                  #close Modal after saving
                  self.learnersDashboardUI.closeDecisionUpdateModal()

                  #toast success/error message
                  self.learnersDashboardUI.saveDecisionToast(saveResponse)
                  self.learnersDashboardUI.updateStatusColor(status, decisionData)
                  if decisionData.decisions['stage'] == 1
                    self.learnersDashboardUI.updateDecisionsDropdown()
      else
        self.learnersDashboardUI.displayErrorText("#decision-reason-error", "Select Valid Reasons")
    else
      self.learnersDashboardUI.displayErrorText("#decision-status-error", "Select a Decision")

