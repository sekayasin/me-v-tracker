class LearningOutcomes.App
  constructor: ->
    @learningOutcomesUI = new LearningOutcomes.UI()
    @learningOutcomesApi = new LearningOutcomes.API()
    @sortApp  = new Sorting.App()
    @curriculumApp = new Curriculum.App()
    @programId = localStorage.getItem('programId')

  start: =>
    if window.location.search.includes("search")
      @curriculumApp.fetchSearchDetails()
    else
      @learningOutcomesUI.initializeLearningOutcomes(
        @learningOutcomesApi
        @includeAdminStatus,
        @getSortedOutcomes
      )

      @learningOutcomesApi.fetchLearningOutcomes(@programId).then (learningOutcome) =>
        @learningOutcomesUI.populateSwitchingTabs(learningOutcome)

    @numberOfOutcomes()

    @learningOutcomesUI.addOutcomeModalActions(
      @learningOutcomesApi.fetchFrameworkCriteriumId,
      @learningOutcomesApi.fetchCriteria
    )

    @learningOutcomesUI.floatTableHeader()

    @learningOutcomesUI.submitLearningOutcome(
      @learningOutcomesApi
    )

    @learningOutcomesUI.editOutcomeModalActions(
      @getAssessment,
      @learningOutcomesApi.fetchCriteria
    )
    @learningOutcomesUI.archiveOutcomeWarningModal(@deleteAssessment)

    @learningOutcomesUI.refreshLearningOutcomesTable(
      @learningOutcomesApi,
      @includeAdminStatus,
      @getSortedOutcomes
    )

  prepareSortableLearningOutcomes: (learningOutcomes) =>
    sortableLearningOutcomes = learningOutcomes
    sortableLearningOutcomes.map (outcome) -> outcome["name"] = outcome.assessment.name
    return sortableLearningOutcomes

  getSortedOutcomes: (allOutcomes, orderBy, sortField) =>
    @sortApp.sort(
      @prepareSortableLearningOutcomes(allOutcomes.assessments),
      orderBy,
      sortField
    )

  includeAdminStatus: (outcomesData) =>
    outcomesWithAdminStatus = outcomesData
    outcomesWithAdminStatus.assessments.map (outcome) -> outcome["isAdmin"] = outcomesWithAdminStatus.is_admin
    return outcomesWithAdminStatus

  numberOfOutcomes: () =>
    @learningOutcomesApi.fetchLearningOutcomes(@programId).then (data) ->
      localStorage.setItem('OutcomeCount', data["assessments"].length)

  getAssessment: (assessmentId) =>
    return @learningOutcomesApi.fetchAssessment(assessmentId)

  deleteAssessment: (assessmentId) =>
    return @learningOutcomesApi.deleteAssessment(assessmentId)
