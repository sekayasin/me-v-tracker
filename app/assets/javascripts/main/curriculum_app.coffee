class Curriculum.App
  constructor: ->
    @curriculumUI = new Curriculum.UI()
    @curriculumApi = new Curriculum.API()
    @sort  = new Sorting.App()
    @program = new Program.API()
    @learningOutcomeUI = new LearningOutcomes.UI()
    @criteriaDetails = {}
    @allCriteria = {}
    @programId = localStorage.getItem('programId')

  start: ->
    @initializeTable()
    @curriculumUI.sortIconListener(@sortCriteriaTable)
    @curriculumUI.criteriaFilterListener(@filterCriteriaByFramework)
    @curriculumUI.addCriteriaListener()
    @curriculumUI.criteriaCheckboxListener()
    @populateSwitchingTabs()
    @curriculumUI.submitCriteria()
    @curriculumUI.updateClickedFramework()

  initializeTable: ->
    self = @

    if window.location.search.includes("search")
      self.fetchSearchDetails()
    else
      self.curriculumApi.fetchCurriculumDetails(self.programId).then (data) ->
        self.setupTableData(data)

  fetchSearchDetails: ->
    self = @
    query = JSON.parse(window.localStorage.getItem('searchDetails')).query

    self.curriculumApi.fetchSearchResults(query, self.programId).then (data) ->
      criteriaLength = data.criteria.length
      learningOutcomeLength = data.assessment.length
      self.setupTableData(data)
      self.learningOutcomeUI.populateLearningOutcomesTable(data.assessment)
      self.learningOutcomeUI.populateSwitchingTabs(data.assessment)
      self.curriculumUI.searchHeader(criteriaLength + learningOutcomeLength)

  setupTableData: (data) ->
    self = @
    self.criteriaDetails = data
    self.allCriteria = Object.assign({}, data)
    sortedCriteria = @sort.sort(data["criteria"], 1, 'criteria')
    self.curriculumUI.populateCriteriaTable(sortedCriteria, data)
    @curriculumUI.editCriteriaListener()

  getFilteredCriteriaList: (allCriteria, frameworkId) ->
    filteredCriteria = []
    for key, criterium of allCriteria.criteria
      for key, criteria_framework of criterium.frameworks
        if criteria_framework.id is frameworkId
          filtered_result = criterium
          if criterium not in filteredCriteria
            filteredCriteria.push(filtered_result)

    return filteredCriteria

  filterCriteriaByFramework: (frameworkId) =>
    self = @
    frameworkIdList = @allCriteria.frameworks.map (framework) -> framework.id

    if frameworkId in frameworkIdList
      filteredCriteria = self.getFilteredCriteriaList(@allCriteria, frameworkId)
      self.criteriaDetails = { criteria: filteredCriteria, frameworks: @allCriteria.frameworks}
      self.curriculumUI.populateCriteriaTable(filteredCriteria, @allCriteria)
    else
        filteredCriteria = @allCriteria.criteria
        self.criteriaDetails = @allCriteria
        self.curriculumUI.populateCriteriaTable(filteredCriteria, @allCriteria)

  sortCriteriaTable: (criteriaData, orderBy, sortField, elementClicked) =>
    self = @
    criteriaData = @criteriaDetails unless criteriaData
    sortedCriteria = @sort.sort(criteriaData["criteria"], orderBy, sortField)

    self.curriculumUI.populateCriteriaTable(sortedCriteria, @allCriteria)
    self.curriculumUI.sortOrderIcon(orderBy, elementClicked)

  populateSwitchingTabs: =>
    self = @

    if window.location.search.includes("search")
      query = JSON.parse(window.localStorage.getItem('searchDetails')).query

      self.curriculumApi.fetchSearchResults(query, self.programId).then (data) ->
        criteriaLength = data.criteria.length
        outcomeLength = data.assessment.length

        result = if criteriaLength != 1 then 'Matches Found' else 'Match Found'
        self.curriculumUI.populateSwitchingTabs(criteriaLength + " #{result}")

        self.curriculumUI.disableEmptyTabs(criteriaLength, outcomeLength)
    else
      self.curriculumApi.fetchCurriculumDetails(self.programId).then (criteria) ->
        self.program.fetch(self.programId).then (program) ->
          self.curriculumUI.populateSwitchingTabs(
            criteria['criteria'].length,
            program.name,
            criteria['frameworks'].length
          )
