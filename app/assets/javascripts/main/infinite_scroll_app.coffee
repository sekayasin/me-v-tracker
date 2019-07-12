class InfiniteScroll.App
  constructor: ->
    @columnFilterUI = new ColumnFilter.UI()
    @infiniteScrollApi = new InfiniteScroll.API()
    @infiniteScrollUI = new InfiniteScroll.UI()
    @learnersTableUI = new LearnersTable.UI()
    @learnersDashboardUI = new LearnersDashboard.UI()
    @learnersDashboardApp = new LearnersDashboard.App()
    @learnersDashboardApi = new LearnersDashboard.API()
    @decisionHistoryApi = new DecisionHistory.Api()
    @observer = new Observer.App()

  start: =>
    self = @
    pageSize = 15
    if $('.pagination').length
      $('.pane-vScroll').scroll ->
        url = $('.pagination a[rel=next]').attr('href')
        scrollTop = $(@).prop("scrollTop")
        scrollHeight = $(@).prop("scrollHeight")
        clientHeight = $(@).prop("clientHeight")

        if url and scrollTop == (scrollHeight - clientHeight) and $('.campers-table-body > tr').length % pageSize == 0
          if self.infiniteScrollUI.getScrollBottomStatus() == false
            $('#loader').addClass 'loader'
            self.infiniteScrollApi.getCampersRecord(url)
            self.observer.setMutationObserver(
              self.infiniteScrollUI.getTableRecords('#campers-table-records'),
              self.beforeScroll,
              self.afterScroll
            )
            self.infiniteScrollUI.setScrollBottomStatus(true)

  afterScroll: =>
    self = @
    self.infiniteScrollUI.scrollBottomStatus = false
    self.infiniteScrollUI.removeLoader()

  beforeScroll: (addedElements) =>
    self = @
    self.columnFilterUI.hideUncheckedColumn()
    self.learnersDashboardUI.closeDecisionAndLFADropdownsByIcon()
    self.learnersDashboardUI.changeLearnerStatus(
      self.infiniteScrollUI.findElement(addedElements, '.decision-item'),
      self.learnersDashboardApi.getDecisionReason,
      self.decisionHistoryApi.getDecisionHistory
    )
    self.learnersDashboardUI.changeDecisionStatus(self.learnersDashboardApi.getDecisionReason, self.decisionHistoryApi.getDecisionHistory)
    self.learnersTableUI.updateDecisionsDropdownState()
    self.learnersDashboardUI.closeDecisionUpdateModal()
    self.learnersTableUI.setLfaDropdownState()
