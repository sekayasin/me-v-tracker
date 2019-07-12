class LearnersTable.App
  constructor: ->
    @learnersTableUI = new LearnersTable.UI()
    @infiniteScrollApi = new InfiniteScroll.API()
    @infiniteScrollUI = new InfiniteScroll.UI()
    @learnersDashboardApi = new LearnersDashboard.API()
    @learnersDashboardApp = new LearnersDashboard.App()
    @learnersDashboardUI = new LearnersDashboard.UI()
    @learnersTableApi = new LearnersTable.API()
    @columnFilterUI = new ColumnFilter.UI()
    @decisionHistoryApi = new DecisionHistory.Api()
    @observer = new Observer.App()
    @handleLfaUpdate()

  start: =>
    @learnersTableUI.initializeFiltering(
      @initializeTableUpdater(),
      @initializeFilters(),
      @fetchFilterData
    )
    @learnersTableUI.setTableDecisionState(@learnersTableUI.decisionOneSelections, @learnersTableUI.decisionTwoSelections)
    @learnersTableUI.setLfaDropdownState()
    @learnersTableUI.clearFilters()
    @learnersTableUI.saveFilters()

  initializeTableUpdater: =>
    self = @
    $('.btns.apply-btn').off 'click'
    $('.btns.apply-btn').on 'click', ->
      self.learnersTableUI.saveFilters()
      self.learnersTableUI.updateFilterCount()
      self.learnersTableUI.prepareTable()
      self.learnersTableUI.moveScrollBar(0)

      setTimeout (->
        self.learnersTableUI.removeFilteringLoader()
        self.learnersTableUI.clearCurrentRecords()
        self.infiniteScrollApi.getCampersRecord(self.learnersTableUI.getFilterParams() + "&page=1")
        tableRecords = self.infiniteScrollUI.getTableRecords('#campers-table-records')
        self.observer.setMutationObserver(
          tableRecords, self.beforeUpgrade
        )
        return
      ), 2000

  initializeFilters: =>
    self = @
    if localStorage.getItem('filterOptions') and !window.location.search.split('&')[1]

      if JSON.parse(localStorage.getItem('filterOptions')).program_id == localStorage.getItem('programId')
        self.learnersTableUI.updateFilterCount()
        self.learnersTableUI.prepareTable()
        self.learnersTableUI.moveScrollBar(0)

        setTimeout (->
          self.learnersTableUI.removeFilteringLoader()
          self.learnersTableUI.clearCurrentRecords()
          self.infiniteScrollApi.getCampersRecord(self.learnersTableUI.getFilterParams() + "&page=1")
          tableRecords = self.infiniteScrollUI.getTableRecords('#campers-table-records')
          self.observer.setMutationObserver(
            tableRecords, self.beforeUpgrade
          )
          return
        ), 2000

        self.learnersTableUI.populateCheckboxes()


  beforeUpgrade: (addedElements) =>
    self = @
    self.columnFilterUI.hideUncheckedColumn()
    self.learnersDashboardUI.closeDecisionAndLFADropdownsByIcon()
    self.learnersDashboardUI.changeLearnerStatus(
      self.infiniteScrollUI.findElement(addedElements, '.decision-item'),
      self.learnersDashboardApi.getDecisionReason,
      self.decisionHistoryApi.getDecisionHistory
    )
    self.learnersTableUI.updateDecisionsDropdownState()
    self.learnersTableUI.setLfaDropdownState()

  handleLfaUpdate: =>
    @learnersTableUI.handleLfaUpdate(@learnersTableApi.updateLearnerLfa)

  fetchFilterData: (filterParams)=>
    @learnersTableApi.fetchFilterMeta(filterParams)
