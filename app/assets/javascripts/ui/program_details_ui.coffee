class ProgramDetails.UI
  constructor: (programId) ->
    @programId = programId
    @programPhasesDetails = null
    @emptyState = new EmptyState.UI()
    @loaderUI = new Loader.UI()
  
  fetchProgramDetails: (getProgramDetails) =>
    self = @
    getProgramDetails(self.programId).then (details) ->
      self.programPhasesDetails = details
      self.initializeProgramDetails()
  
  initializeProgramDetails: () =>
    self = @
    if self.programPhasesDetails isnt null and !('error' of self.programPhasesDetails)
      self.populateProgramDescription(self.programPhasesDetails)

      if self.programPhasesDetails.assessments.length > 0
        self.removeNoDataText()
        self.populateProgramPhaseDetails(self.programPhasesDetails)
        self.handleOnPhaseSwitch()
        firstPhaseId = parseInt($('.program-phases-wrapper').find(".program-phase").first().find(".phase-number").attr('id').split("_")[2])
        self.populateProgramPhaseTable(self.programPhasesDetails, firstPhaseId)
      else
        $('.program-phases-wrapper').hide()
        self.removeNoDataText()
        $('.program-details-table-wrapper').html self.emptyState.getNoContentText()
    else
      $('#program-details-panel').html self.emptyState.getNoContentText()

  handleOnPhaseSwitch: () =>
    self = @
    $('.upcoming-phase').on 'click', (event) ->
      phaseId = parseInt($(this).attr("id").split('_')[2])
      self.populateProgramPhaseTable(self.programPhasesDetails, phaseId)

  populateProgramDescription: (programPhasesDetails) =>
    self = @
    programDuration = self.buildProgramDuration(programPhasesDetails.duration)
    programLanguageStack = self.buildProgramLanguageStack(programPhasesDetails.language_stack)
    programCadence = self.buildProgramCadence(programPhasesDetails.cadence)
    $('.program-desc.program-duration').html(programDuration)
    $('.program-desc.program-language-stack').html(programLanguageStack)
    $('.program-desc.program-cadence').html(programCadence)
  
  buildProgramLanguageStack: (languageStacks) ->
    programLanguageStack = ''
    
    $.each languageStacks, (index, language) ->
      if languageStacks.length is (index + 1)              
        programLanguageStack += language.name
      else
        programLanguageStack += language.name + ','

    programLanguageStack

  buildProgramCadence: (cadence) ->
    programCadence = if cadence == null then "N/A" else cadence

  buildProgramDuration: (days) ->
      displayText = if days > 1 then "#{days} days" else "#{days} day"

      switch displayText
        when '0 day' then 'No Duration Set'
        when 'null day' then 'No Duration Set'
        else displayText
  
  populateProgramPhaseDetails: (programDetails) =>
    self = @
    phaseSectionTemplate = self.buildProgramPhasesTemplate(programDetails.assessments)
    $('.program-phases-wrapper').html(phaseSectionTemplate).find(".program-phase").first().find(".phase-number").addClass('active-phase')

  buildProgramPhasesTemplate: (phasesDetails) =>
    self = @
    decisionNumber = 1
    phaseSectionTemplate = ""
    
    $.each phasesDetails, (index, phaseDetail) ->
      if !phaseDetail.phase_decision
        phaseSectionTemplate += 
        "
          <div class='program-phase'>
            <div id='phase_id_#{phaseDetail.phase_id}' class='phase-number upcoming-phase prog-details-two'> #{index + 1} </div>
            <div class='program-phase-detail'>
              <p class='program-phase-title'>
                #{phaseDetail.phase_name}
              </p>
              <p class='program-no-of-days'>#{self.buildProgramDuration(phaseDetail.phase_duration)}</p>
            </div>
          </div>
        "
      else
        phaseSectionTemplate +=
        " 
          <div class='program-phase'>
            <div id='phase_id_#{phaseDetail.phase_id}' class='phase-number upcoming-phase'> #{index + 1} </div>
            <div class='program-phase-detail'>
              <p class='program-phase-title'>
              </p>
              <p class='program-no-of-days'>#{self.buildProgramDuration(phaseDetail.phase_duration)}</p>
            </div>
          </div>
          <div class='program-phase'>
            <div id='decision_bridge_after_#{phaseDetail.phase_name}' class='phase-number phase-decision-bridge'> D </div>
            <div class='program-phase-detail'>
              <p class='program-phase-title decision-bridge'>
                Decision #{decisionNumber}
              </p>
            </div>
          </div>
        "
        decisionNumber += 1

    phaseSectionTemplate
  
  populateProgramPhaseTable: (programPhasesDetails, phaseId=1) ->
    self = @
    $('.program-phases-wrapper').find(".active-phase").removeClass("active-phase")
    $('.program-phases-wrapper').find("#phase_id_#{phaseId}").addClass("active-phase")
    allPhasesDetails = programPhasesDetails.assessments

    currentPhaseDetails = allPhasesDetails.filter (phaseDetail) ->
      phaseDetail.phase_id is phaseId

    if currentPhaseDetails[0].assessments.length > 0
      self.removeNoDataText()
      $('.program-details-table-wrapper').show()
      $('.values-alignment-data').html(self.getFrameworkAssessments(currentPhaseDetails[0].assessments, 2))
      $('.output-quality-data').html(self.getFrameworkAssessments(currentPhaseDetails[0].assessments, 1))
      $('.feedback-incorporation-data').html(self.getFrameworkAssessments(currentPhaseDetails[0].assessments, 3))
    else
      self.removeNoDataText()
      $('.program-details-table-wrapper').hide()
      $("#{self.emptyState.getNoContentText()}").insertBefore(".program-details-table-wrapper")

  getFrameworkAssessments: (phaseAssessment, frameworkId) =>
    frameworkAssessment = ''
    criterium = []
    $.each phaseAssessment, (index, assessment) ->
      
      if assessment.framework_id is frameworkId
        filteredCriteria = criterium.filter (data) -> data is assessment.criteria_name    
        
        if filteredCriteria.length is 0
          criterium.push(assessment.criteria_name)
    
    assessmentList = []
    $.each criterium, (index, criteria) ->
      filteredCriteriaAssessments = phaseAssessment.filter (data) -> criteria is data.criteria_name
      
      assessmentList.push({ criteria: criteria, filtered_assessments: filteredCriteriaAssessments})
    
    $.each assessmentList, (index, assessments) ->
      assessmentsList = ''
      
      $.each assessments.filtered_assessments, (value, assessment) ->
        assessmentsList += '<li>' + assessment.assessment_name + '</li>'        
      frameworkAssessment += "<span>#{assessments.criteria}</span><ul class='dashed'>#{assessmentsList}</ul>"
    
    if frameworkAssessment.length > 0 then frameworkAssessment else 'N/A'

  removeNoDataText: ->
    $('.no-data-text').remove()
