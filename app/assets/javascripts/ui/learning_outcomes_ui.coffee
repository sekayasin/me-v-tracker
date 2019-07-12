class LearningOutcomes.UI
  constructor: ->
    @emptyState = new EmptyState.UI()
    @archiveConfirmationModal = new Modal.App('#archive-confirmation-modal', 500, 500, 255, 255)
    @modal = new Modal.App('#add-learner-outcome', 900, 900, 'auto', 900)
    @loaderUI = new Loader.UI()
    @curriculumUI = new Curriculum.UI()
    @truncateText = new TruncateText.UI()
    allOutcomes = {}
    @programId = localStorage.getItem('programId')
    @assessmentId = ''
    @assessmentTypes = null
    @contentPerPage = 10
    @pagesCount = 0
    @pagination = new PaginationControl.UI()
    @filterParamsChanged = false

  initializeLearningOutcomes: (
    loadLearningOutcomes,
    includeAdminStatus,
    getSortedOutcomes
  ) =>
    self = @
    @selectDefaultProgram()
    $(".learning-outcomes-panel").click =>
      @resetFilterDropdowns()
      @checkScreenSize()
      $(".learning-outcomes-body-wrapper").width($(window).width())

      @refreshLearningOutcomesTable(
        loadLearningOutcomes,
        includeAdminStatus,
        getSortedOutcomes
      )
      @registerProgramDropdownListener(loadLearningOutcomes,
        includeAdminStatus,
        getSortedOutcomes)
      @handleTableHeaderScroll()

  selectDefaultProgram: ->
    $("#program-filter-outcome").val(@programId)
  
  registerProgramDropdownListener: (
        loadLearningOutcomes,
        includeAdminStatus,
        getSortedOutcomes
  ) ->
      $('#program-filter-outcome, .framework-filter-outcome, .criteria-filter-outcome').on "selectmenuchange", =>
        targetProgramId = $('#program-filter-outcome').val()
        @programId = targetProgramId
        $(".learning-outcomes-body-wrapper").scrollTop(0)
        @refreshLearningOutcomesTable(loadLearningOutcomes, includeAdminStatus, getSortedOutcomes, targetProgramId)
        
  initializePagination: (data, count, includeAdminStatus, api) =>
    @pagination.contentPerPage = @contentPerPage
    @pagination.populateTable = @populateLearningOutcomesTable.bind(this)
    @pagination.contentApi = (path) => api.fetchLearningOutcomes(@programId, "#{path}&#{@yieldSelectedFrameworkAndCriteria()}")
    keyInResponse = "assessments"
    changeTextOfOutcomesPanel = (count) ->
          $('#outcomes:visible').html("#{count}")
    @pagination.buildInitialPages(data, count, keyInResponse, changeTextOfOutcomesPanel, includeAdminStatus)

  resetFilterDropdowns: =>
    $("#framework-filter-outcome").prop("selectedIndex", 0)
    $("#criteria-filter-outcome").html("<option>All</option>")
    $("#framework_criterium_criterium_id").html("<option>Select Criterion</option>")
    $("select").selectmenu("destroy").selectmenu({ style: "dropdown" })

  populateLearningOutcomesTable: (learningOutcomes) -> 
    self = @
    $("#learning-outcomes-body").html("")
    if learningOutcomes.length == 0
      if parseInt(localStorage.getItem('OutcomeCount')) == 0
        $(".criterium-filter-wrapper").hide()
        $(".framework-filter-wrapper").hide()
        $(".outcomes-header-table").addClass("hide-header-table")
        $("#learning-outcomes-body").append(@emptyState.getNoContentText())
      else
        $(".outcomes-header-table").addClass("hide-header-table")
        $("#learning-outcomes-body").append(@emptyState.getNoContentText())
    else
      $(".outcomes-header-table").removeClass("hide-header-table")
      for outcome in learningOutcomes
        metrics = outcome.metrics
        metricOption = "<ul class='metric-list'><b class='metric-text'>Metrics</b>"
        for metric in metrics
          metricOption += "<li class='metric-options'>#{metric.point} - #{metric.description}</li>"
        
        metricOption += "</ul> <div class='show-more'>...Show more</div>"
        metricOptionContent = $.parseHTML(metricOption)[0].innerText

        actionColumn = if outcome.isAdmin then "<td class='action-data'> 
        <span class='edit-icon tour-edit-icon' data-assessment-id=#{outcome.assessment.id}> </span>
        <span id='#{outcome.assessment.id}' class='archive-icon'>
        <i class='fa fa-archive fa-2x' aria-hidden='true'></i>
        </span></td>" else ""
        learning_outcomes_row =
          "<tr class='outcomes-row-wrapper' data-assessment-id=#{outcome.assessment.id}>
              <td class='outcome-data'> <span>#{outcome.assessment.name}</span></td>
              <td class='description-data'>
               <span>
               #{self.truncateText.generateContent(outcome.assessment.description, 110)[0].innerHTML}
               </span></td>
              <td class='output-data'>
               <span>
               #{self.truncateText.generateContent(outcome.assessment.expectation, 110)[0].innerHTML || 'Output Not Specified'}
               </span></td>
              <td class='context-data'>
               <span><b class='context-text'>Context</b> <br>
                <span>#{self.truncateText.generateContent(outcome.assessment.context, 110)[0].innerHTML}
                </span></span>#{metricOption}</td>
              <td class='framework-data'> <span>#{outcome.framework}</span></td>
              <td class='criterium-data'> <span>#{outcome.criteria}</span></td>
              #{actionColumn}
          </tr>"
        $("#learning-outcomes-body").append(learning_outcomes_row)
      self.truncateText.activateShowMore()
      if $('.metric-options').length > 3
        $('.metric-options:gt(0)').hide();
        $('.show-more').show();
        $('.show-more').on 'click', ->
          $(this).parent('.context-data').find('.metric-options:gt(0)').toggle();
          $(this).text if $(this).text() == "...Show more" then "Show less" else "...Show more";

  getSelectedFramework: =>
    return $("#framework-filter-outcome").find(":selected").text()

  getSelectedCriterium: =>
    return $("#criteria-filter-outcome").find(":selected").text()

  populateCriteriumDropdown: (frameworkCriteria) =>
    options = "<option>All</option>"
    for frameworkCriterium in frameworkCriteria
      if frameworkCriterium.framework == @getSelectedFramework()
        options += "<option>#{frameworkCriterium.criteria}</option>"
    $("#criteria-filter-outcome").html(options)
    $("select").selectmenu("destroy").selectmenu({ style: "dropdown" })

  handleFrameworkDropdown: (frameworkCriteria, learningOutcomes) =>
    self = @
    $("#framework-filter-outcome").on "selectmenuchange", ->
      self.populateCriteriumDropdown(frameworkCriteria)
      $(".learning-outcomes-body-wrapper").scrollTop(0)

  handleCriteriumDropdown: (learningOutcomes) =>
    self = @
    $("#criteria-filter-outcome").on "selectmenuchange", ->
      $(".learning-outcomes-body-wrapper").scrollTop(0)

  populateTableOnDropdownSelect: (learningOutcomes) =>
    self = @
    outcomesList = if self.getSelectedFramework().trim() == "All" then learningOutcomes else
      learningOutcomes.filter (outcome) -> outcome.framework == self.getSelectedFramework().trim()
    if self.getSelectedCriterium().trim() != "All"
      outcomesList = outcomesList.filter (outcome) -> outcome.criteria == self.getSelectedCriterium().trim()
    self.populateLearningOutcomesTable(outcomesList)

  sortOrderIcon: (orderBy, elementClicked) ->
    if orderBy == -1
      elementClicked.removeClass("sort-icon-asc-outcomes").addClass("sort-icon-desc-outcomes")
    else
      elementClicked.removeClass("sort-icon-desc-outcomes").addClass("sort-icon-asc-outcomes")

  sortIconListener: (getSortedData) =>
    self = @
    $(".sort-icon-outcomes").on "click", (event) ->
      event.stopImmediatePropagation()
      orderBy = if $(this).css("background-image").includes("a-z") then -1 else 1
      self.sortOrderIcon(orderBy, $(this))
      self.populateTableOnDropdownSelect(getSortedData(self.allOutcomes, orderBy, "name"))

  handleTableHeaderScroll: =>
    $(".learning-outcomes-table-wrapper").scroll ->
      $(".learning-outcomes-body-wrapper").width($(".learning-outcomes-table-wrapper").width() + $(".learning-outcomes-table-wrapper").scrollLeft())
      return

  checkScreenSize: =>
    $(window).resize ->
      $(".learning-outcomes-body-wrapper").width($(".learning-outcomes-table-wrapper").width() + $(".learning-outcomes-table-wrapper").scrollLeft())

  populateSwitchingTabs:(learningOutcomes) =>
    self = @
    if window.location.search.includes("search")
      outcomeLength = learningOutcomes.length
      result = if outcomeLength != 1 then 'Matches Found' else 'Match Found'
      $('span#outcomes').html(outcomeLength + " #{result}")

      if outcomeLength == 0
        self.curriculumUI.disableSwitchingTabs('.learning-outcome-tab')
    else
      $('span#outcomes').html(learningOutcomes["assessments"].length)

  # populate criteria dropdown in modal
  populate_criteria_list: (framework_id, fetchCriteria) =>
    self = @
    options = "<option>Select Criterion</option>"
    fetchCriteria(framework_id, self.programId).then (data) =>
      for criterium in data
        options += "<option value=#{criterium.id}>#{criterium.name}</option>"
      $("#framework_criterium_criterium_id").html(options)
      $("#framework_criterium_criterium_id").selectmenu("destroy").selectmenu({ style: "dropdown" })
    return

  addOutcomeModalActions:(fetchFrameworkCriteriumId, fetchCriteria) =>
    self = @
    $(".add-outcome").click ->
      self.modal.open()
      self.clearModal()
      self.modal.setHeaderTitle('.learner-outcome-modal-header', 'Add Learning Outcome')
      self.togglePageScroll('hidden')
      self.showHideSubmissionTypes(false)
      self.handleRequireSubmissionChange()
      self.toggleMultipleSubmissions()

    $(".new_assessment").submit ->
      self.modal.close()
      self.flushAllValues()
      self.togglePageScroll('auto')
      document.location.href = "/curriculum#learning-outcomes-panel"
      self.resetModalFilters()

    $('.ui-widget-overlay, .close-add-learner-outcome-modal').click ->
      self.clearModal()
      self.modal.close()
      self.togglePageScroll('auto')
      self.resetModalFilters()
      self.assessmentData = null
      self.flushValues()
      self.flushAllValues()

    $('#framework_criterium_framework_id').on 'selectmenuchange', ->
      framework_id = $('#framework_criterium_framework_id').val()
      self.populate_criteria_list(framework_id, fetchCriteria)
      return

    # set framework_criterium_id on criterium change
    $('#framework_criterium_criterium_id').on 'selectmenuchange', ->
      framework_id = $('#framework_criterium_framework_id').val()
      criterium_id = $('#framework_criterium_criterium_id').val()

      fetchFrameworkCriteriumId(framework_id, criterium_id).then (response) =>
        $('#framework-criterium-id').val(response)
      return

  editOutcomeModalActions: (getAssesment) =>
    self = @
    $('#learning-outcomes-body').on 'click', 'span.edit-icon', ->
      self.modal.open()
      self.modal.setHeaderTitle('.learner-outcome-modal-header', 'Edit Learning Outcome')
      assessmentId = $(this).attr('data-assessment-id')
      self.togglePageScroll('hidden')
  
  archiveOutcomeWarningModal: (deleteAssessment) =>
    self = @
    $('#learning-outcomes-body').on 'click', 'span.archive-icon', ->
      self.archiveConfirmationModal.open()
      self.assessmentId = $(this).attr('id')
      self.cancelArchive()
    $('#confirm-archive-outcome').click (event) ->
      event.preventDefault()
      deleteAssessment(self.assessmentId).then (data) ->
        if data.archived
          deletedAssessment = $('#learning-outcomes-body').find("[data-assessment-id=#{data.id}]")
          deletedAssessment.remove()
          self.assessmentId = null
          localStorage.setItem('OutcomeCount', parseInt(localStorage.getItem('OutcomeCount'), 10) - 1)
          $('span#outcomes').html(localStorage.getItem('OutcomeCount'))
          self.archiveConfirmationModal.close()
          $('.toast').messageToast.start(data.message, "success")
        else
          $('.toast').messageToast.start(data.error, "error")

  cancelArchive: ->
    self = @
    $('div#archive-confirmation-modal').find('a.btn-cancel, .btn-cancel').click (event) ->
      self.archiveConfirmationModal.close()

  togglePageScroll: (style) =>
    $('body').css('overflow', style)

  resetModalFilters: () =>
    $("#framework_criterium_criterium_id").selectmenu('destroy').prop("selectedIndex", 0).selectmenu()
    $("#framework_criterium_framework_id").selectmenu('destroy').prop("selectedIndex", 0).selectmenu()

  floatTableHeader: ->
    setVariables = ->
      if $( document ).width() > 1152
        @tableHeight = 240
        @scrollHeight = 259
      else if $( document ).width() <= 1152 and $( document ).width() > 890
        @tableHeight = 240
        @scrollHeight = 269
      else if $( document ).width() <= 890 and $( document ).width() > 868
        @tableHeight = 180
        @scrollHeight = 239
      else if $( document ).width() <= 868 and $( document ).width() > 661
        @tableHeight = 180
        @scrollHeight = 349
      else if $( document ).width() <= 661 and $( document ).width() > 499
        @tableHeight = 180
        @scrollHeight = 419
      else if $( document ).width() <= 499 and $( document ).width() > 360
        @tableHeight = 140
        @scrollHeight = 649
      else if $( document ).width() <= 360 and $( document ).width() > 319
        @tableHeight = 135
        @scrollHeight = 729

    fixedHeader =(tableHeight, scrollHeight) ->
      if document.body.scrollTop > scrollHeight or document.documentElement.scrollTop > scrollHeight
        $('#learning-outcomes-table').addClass('fix-table')
        $('.outcomes-header-table').addClass('header-margin')
        $('.mdl-mini-footer').hide()
        $('.learning-outcomes-body-wrapper').height($(window).height() - tableHeight)
        $('.learning-outcomes-body-wrapper').addClass('scroll-table-body')
        $('.learning-outcomes-table').addClass('scroll-margin')

        if $('.learning-outcomes-body-wrapper').scrollTop() + $('.learning-outcomes-body-wrapper').height() == $('.learning-outcomes-body-wrapper')[0].scrollHeight
          $('.mdl-mini-footer').show()
          $('.learning-outcomes-body-wrapper').height($(window).height() - tableHeight)

    showFooter = (tableHeight, scrollHeight)->
      if $('.learning-outcomes-body-wrapper').scrollTop() + $('.learning-outcomes-body-wrapper').height() == $('.learning-outcomes-body-wrapper')[0].scrollHeight
        $('.mdl-mini-footer').show()

        if @scrollHeight == 729 or  @scrollHeight == 649
          $('body').css('position': 'fixed')
          $('.mdl-mini-footer').css('cssText','margin-top : -200px !important;')

      else if $('div.learning-outcomes-body-wrapper').scrollTop() == 0 and document.body.scrollTop < scrollHeight
        $('#learning-outcomes-table').removeClass('fix-table')
        $('.outcomes-header-table').removeClass('header-margin')
        $('.mdl-mini-footer').show()
        $('.learning-outcomes-body-wrapper').height($(window).height() - tableHeight)
        $('.learning-outcomes-body-wrapper').removeClass('scroll-table-body')
        $('.learning-outcomes-table').removeClass('scroll-margin')

      else
        $('.mdl-mini-footer').hide()
        $('.learning-outcomes-body-wrapper').height($(window).height() - tableHeight)
        $(document).scrollTop(0)
        $('body').css('position': 'unset')
        $('.mdl-mini-footer').css('cssText','display : none;')

   
    $('.learning-outcomes-body-wrapper').scroll ->
      setVariables()
      showFooter(tableHeight, scrollHeight)
    return

  editOutcomeModalActions: (getAssesment, fetchCriteria) =>
    self = @
    $('#learning-outcomes-body').on 'click', 'span.edit-icon', ->
      self.showHideSubmissionTypes(false)
      self.loaderUI.show()
      self.modal.open()
      self.toggleMultipleSubmissions()
      self.modal.setHeaderTitle('.learner-outcome-modal-header', 'Edit Learning Outcome')
      $(".learning-outcome-btn").removeClass("add").addClass("edit")
      self.assessmentId = $(this).attr('data-assessment-id')

      getAssesment(self.assessmentId).then (data) ->
        self.assessmentData = data
        self.populateEditModal(data, fetchCriteria)
        self.loaderUI.hide()
        self.configureSubmissionTypes()

      self.togglePageScroll('hidden')

      self.handleRequireSubmissionChange()

  populateEditModal: (assesmentData, fetchCriteria) =>
    self = @
    @assessmentData = assesmentData
    $("#assessment-name-id").val(assesmentData.name)
    $("#assessment-description").val(assesmentData.description)
    $("#assessment-expectation").val(assesmentData.expectation)

    self.populateFrameworkDropdownEditModal(
      assesmentData.framework_name,
      assesmentData.framework_id,
      fetchCriteria
    )

    self.populateCriterionDropdownEditModal(
      assesmentData.criteria_name
    )

    $("#context").val(assesmentData.context)
    $("#N\\/R").val(assesmentData.metrics[0].description)
    $("[id='Below Expectations']").val(assesmentData.metrics[1].description)
    $("[id='At Expectations']").val(assesmentData.metrics[2].description)
    $("[id='Exceeds Expectations']").val(assesmentData.metrics[3].description)

    if assesmentData.requires_submission
      $('#requires_submission').prop('checked', true)
      self.showHideSubmissionTypes(true)
      $(".requires-submission").each (index, element) ->
        element.MaterialCheckbox.check()
      self.populateSubmissionTypes(assesmentData.submission_types)
    else
      self.showHideSubmissionTypes(false)

  populateFrameworkDropdownEditModal: (framework_name, framework_id, fetchCriteria) =>
    self = @

    $("#framework_criterium_framework_id option").each ->
      framework_index = $(this).index()
      framework_value = $(this).text()

      if framework_value == framework_name
        $("#framework_criterium_framework_id").prop("selectedIndex", framework_index)
        $( '#framework_criterium_framework_id').selectmenu( "refresh")

        self.populate_criteria_list(framework_id, fetchCriteria)

  populateCriterionDropdownEditModal: (criteria_name) =>
    self = @

    setTimeout ( ->
      $("#framework_criterium_criterium_id option").each ->
        criteria_index = $(this).index()
        criteria_value = $(this).text()

        if criteria_value == criteria_name
          $("#framework_criterium_criterium_id").prop("selectedIndex", criteria_index)
          $( '#framework_criterium_criterium_id').selectmenu( "refresh")

    ), 1000

  populateSubmissionTypes: (submission_types) ->
    s_types = if submission_types then submission_types.split(", ") else []
    $(".submission-types__input").each (index, element) ->
      unless s_types.indexOf($(element).val()) == -1
        $(element).prop('checked', true)
    $(".submission-types-label").each (index, element) ->
      unless s_types.indexOf($(element).attr("label-value")) == -1
        element.MaterialCheckbox.check()

  clearModal: () =>
    self = @
    self.clearFormErrors(".learning-outcome-form")

    $("#assessment-name-id").val("")
    $("#assessment-description").val("")
    $("#assessment-expectation").val("")
    $("#context").val("")
    $("#N\\/R").val("")
    $("[id='Below Expectations']").val("")
    $("[id='At Expectations']").val("")
    $("[id='Exceeds Expectations']").val("")
    $('#requires_submission').prop('checked', false)
    $('.submission-types__input').prop('checked', false)
    $(".requires-submission").each (index, element) ->
      element.MaterialCheckbox.uncheck()

  clearFormErrors: (target) ->
    $(target).validate().resetForm()

  getMetricPointId: (index) ->
    return $("input[name='assessment[metrics_attributes][#{index}][point_id]']" ).val()

  getFormInputValue: (target) ->
    return  $(target).val()
  
  checkboxIsChecked: (target) ->
    return $(target).is(":checked")
  
  showHideSubmissionTypes: (show) ->
    if show
      $(".submission-types").show()
    else
      $(".submission-types__input").each (index, element) ->
         $(element).prop('checked', false)
      $(".submission-types-label").each (index, element) ->
        element.MaterialCheckbox.uncheck()
      $(".submission-types").hide()

  handleRequireSubmissionChange: ->
    $("#requires_submission").on "change", () =>
      if @checkboxIsChecked("#requires_submission")
        unless @assessmentData then return @showHideSubmissionTypes(true)
        @showMultipleSubmission()
      else
        #the user explicitly doesn't want submissions
        #so we get rid of the submission_phases created if any3
        @flushAllValues('requiresSubmission', @ridAllSubmissionPhases)
        @assessmentTypes = null
        unless @assessmentData then return @showHideSubmissionTypes()
        @toggleMultipleSubmissions()
    
  showMultipleSubmission: ->
    @toggleMultipleSubmissions(true)
    $('#multiple_submissions').on "selectmenuchange",  =>
       value = $('#multiple_submissions').val()
       if value is "No"
        @flushAllValues('submissionPhases', @ridAllSubmissionPhases)
        @flushAllValues('multipleSubmissions', @ridAllSubmissionPhases)
        return @showHideSubmissionTypes(true)
       @submissionPhasesToBeDeleted = null
       @showHideSubmissionTypes()
       @assessmentTypes ?= {}
       @populatePhasesCheckBoxes()
  
  flushValues: ->
    $('.sub-types').each ->
        $(this).val('')
    $('#multiple-submissions-input-holder').hide()
    
  configureSubmissionTypes: (assessmentId) ->
    @submissionPhasesToBeDeleted = []
    { requires_submission, submission_phases } = @assessmentData
    return unless requires_submission && submission_phases && submission_phases.length
    @showHideSubmissionTypes()
    $('#multiple_submissions').val('Yes')
    $('#multiple_submissions').selectmenu('refresh')
    @phasesMap = @yieldPhasesMap()
    @showMultipleSubmission()
    @populatePhasesCheckBoxes()
 
  yieldPhasesMap: ->
    return {} unless @assessmentData.submission_phases
    map = @assessmentData.submission_phases.reduce((accumulator, subPhase) ->
          accumulator["#{subPhase.phase_id}-#{subPhase.day}"] = subPhase.file_type
          return accumulator
        , {})
    map

  containsSubmissionPhases: ->
      @assessmentData && @assessmentData.submission_phases &&
      @assessmentData.submission_phases.length

  dedupe: (type, day) =>
      return false unless @phasesMap
      key = "#{@selectedPhaseId}-#{day}"
      if @phasesMap[key] && @phasesMap[key] != type
        #we need to update the type to solve
        #the deduping problem
        @toBeUpdated ?= []
        @toBeUpdated.push([ @assessmentData.id, @selectedPhaseId, day, type])
      return @phasesMap[key] == type

  registerEventListenersForElement: (i) ->
    self = @

    addEntryToSubmissionTypes = (entry) =>
        @assessmentTypes ?= {}
        @assessmentTypes[i] ?= []
        entry[3] = @selectedPhaseId
        self.assessmentTypes[i].push(entry)

    getSubmittedTitleAndType = () ->
       type = $("#file-type-for-#{i}").val()
       title = ''
       $("#file-type-for-#{i}").children().each( ->
         if $(this).val() == type
            title = $(this).text()
       )
       { type, title }

    indicateSpecifiedOutput = () =>
      { type, title } = getSubmittedTitleAndType()

      validate = () ->
          unless type && type != 'default'
            error = "Please specify a type for day #{i}"
            $(".toast").messageToast.start(error, "error")
            false
          true
     
       if validate()
            #In the future we could have multiple submissions
            #per day and then dynamically populate this entry array
            defaultTitle = "Assignment"
            defaultPosition = 1
            entry = [defaultTitle, type, defaultPosition]
            addEntryToSubmissionTypes(entry) unless @dedupe(type, i)
            $("#submit-btn-#{i}").html('Remove this submission')
            $("#submit-btn-#{i}").addClass('remove-submission')
            $("#header-for-#{i}").text("#{title}")

            $("#file-type-for-#{i}-menu.ui-menu").children().each ->
              if $(this).text().toLowerCase().includes(type)
                blueBackgroundOverlay = '#D6EAF8'
                $(this).css('backgroundColor', blueBackgroundOverlay)
                $(this).siblings().css('backgroundColor', 'white')
             
    
    $("#file-type-for-#{i}").on "selectmenuchange", (e) ->
          $("#submit-btn-#{i}").text('')
          indicateSpecifiedOutput()
        
    $("#submit-btn-#{i}").on "click", (e) =>
       e.preventDefault()
       if $(e.currentTarget).hasClass('remove-submission')
          $(e.currentTarget).text('')
          $("#header-for-#{i}").text("Please specify a type for day #{i}")
          $(e.currentTarget).removeClass('remove-submission')
          @assessmentTypes ?= {}
          @assessmentTypes[i] = []
          toBeDeletedAssociationTypes = @assessmentData.submission_phases.filter((item) =>
                  item && item.phase_id == @selectedPhaseId && item.day == i
                  ) if @containsSubmissionPhases()
          @submissionPhasesToBeDeleted ?= []
          toBeDeletedAssociationTypes && @submissionPhasesToBeDeleted.push(toBeDeletedAssociationTypes)
          @submissionPhasesToBeDeleted = @submissionPhasesToBeDeleted.flat()
          $("#file-type-for-#{i}-menu.ui-menu").children().each( ->
                $(this).css('backgroundColor', 'white')
          )
          return
       indicateSpecifiedOutput()

  checkForValuesInPhasesMap: (day, brute) ->
    key = "#{@selectedPhaseId}-#{day}"
    if @phasesMap && @phasesMap[key]
      return @phasesMap[key] if brute
      $("#header-for-#{day}").text("#{@phasesMap[key].toUpperCase()} - Day #{day}")
    else
      return 'default' if brute
   
  populateMultipleSubmissionsInput: ->
    $("#multiple-submissions-input-holder").html("")

    startDropdown = ->
      fileTypeDropDown = new JqueryDropdown.App({
          selectDropdownClass: "submission-type-dropdown"
        })
      fileTypeDropDown.start()

    populate = (i) =>
        html = "
                #{$('#multiple-submissions-input-holder').html()}
                <div class='multiple-submission-input'>
                <p id='header-for-#{i}'> Please specify a file type for Day #{i}</p>
                <div class='submission-assessment-view'>
                <div id='container-for-#{i}' class='submission-type-container'></div>
                  <form id='form-for-#{i}'>
                    <div>
                      <select name='assessment-file-type' id='file-type-for-#{i}' value='#{@checkForValuesInPhasesMap(i, true)}' class='submission-type-dropdown'>
                        <option value='default'>Click to change</option>
                        <option value='file'>File Upload Only</option>
                        <option value='description'>Description Only</option>
                        <option value='link'>Link Only</option>
                        <option value='file, link'>Either of the two</option>
                      </select>
                    </div>
                    <p id='submit-btn-#{i}' class='multiple-submit-button'></p>
                  </form>
                  </div>
                </div>"
        @cleanUpAndInsertIntoDom('#multiple-submissions-input-holder', html)
        @checkForValuesInPhasesMap(i)
       
    defaultNumberOfSubmissionDays = 1
    phaseDuration = @selectedPhaseDuration or defaultNumberOfSubmissionDays
    populate i for i in [1..phaseDuration]
    startDropdown()
    @registerEventListenersForElement i for i in [1..phaseDuration]

  toggleMultipleSubmissions: (show) ->
    unless show then return $('.multiple-submissions-holder').hide()
    $('.multiple-submissions-holder').show()
    $('#multiple-submissions-input-holder').show()

  populatePhasesCheckBoxes: (assessmentId = parseInt(@assessmentId)) ->
    return unless @allOutcomes
    assessment = @allOutcomes.assessments.find((entry) -> entry.assessment.id == assessmentId)
    return unless assessment

    options = "<option value='None'>None</option>"

    yieldNumber = (string) ->
      return parseInt(string) unless isNaN(string)
      null

    registerListener = =>
      $("#submission-phase-id").on "selectmenuchange", (e) =>
        { value } = e.currentTarget
        if value is "None"
          return @flushAllValues('submissionPhases')
        @selectedPhaseId = yieldNumber(value.split('-')[0])
        @selectedPhaseDuration = yieldNumber(value.split('-')[1])
        @populateMultipleSubmissionsInput()

    insert = (phase) ->
     options += """
                <option value='#{phase[0]}-#{phase[2]}'>#{phase[1]}</option>
              """

    insert phase for phase in assessment.phases

    html = """
            <label class="select-label"> Select Phase</label>
            <select id="submission-phase-id" class="submission-phase-id submission-phases-modal"
            name="output_submission_phase_id">
            #{options}</select>
          """

    startModal = ->
      submissionPhaseDropdownModal = new JqueryDropdown.App({
        selectDropdownClass: "submission-phases-modal"
      })
      submissionPhaseDropdownModal.start()

    @cleanUpAndInsertIntoDom(".assessment-phases-dropdown", html, startModal)
    registerListener()
  
  cleanUpAndInsertIntoDom: (key, html, callback) ->
    $(key).removeClass('hidden')
    $(key).show()
    $(key).html("")
    $(key).html(html)
    callback && callback()
    
  getSubmissionTypes: ->
    unless @checkboxIsChecked("#requires_submission")
      return null
    unless @assessmentTypes
      submission_types = []
      $(".submission-types__input").each (index, element) =>
        if @checkboxIsChecked(element)
         submission_types.push($(element).val())
      if submission_types.length then return submission_types.join(', ') else return null
    return null if @toBeUpdated && @toBeUpdated.length
    @assessmentTypes

  getSubmissionPhasesInGarbage: ->
    #whenever the admin removes a submission phase, we collect
    #them here, send them to the server along with the update params
    #then the server will perform a bulk delete on the submissionsInGargabe
    #seems less expensive than making a call to delete on each removal
    return null unless @submissionPhasesToBeDeleted
    @submissionPhasesToBeDeleted.map((item) -> item.id)

  getSubmissionPhasesToBeUpdated: ->
    return null unless @toBeUpdated && @toBeUpdated.length
    @toBeUpdated.map((p) ->
       return {
         assessment_id: p[0],
         phase_id: p[1],
         day: p[2],
         file_type: p[3]
         }
       )

  getUpdatedData: ->
    self = @

    metrics_attributes = {
      "0": {
        "point_id": self.getMetricPointId(0),
        "description": self.getFormInputValue("#N\\/R"),
        id: ""
      }

      "1": {
        "point_id": self.getMetricPointId(1)
        "description": self.getFormInputValue("[id='Below Expectations']"),
        id: ""
      }

      "2": {
        "point_id": self.getMetricPointId(2),
        "description": self.getFormInputValue("[id='At Expectations']"),
        id: ""
      }

      "3": {
        "point_id": self.getMetricPointId(3),
        "description": self.getFormInputValue("[id='Exceeds Expectations']"),
        id: ""
      }

    }

    assessment = {
      "name": self.getFormInputValue("#assessment-name-id"),
      "description": self.getFormInputValue("#assessment-description"),
      "expectation": self.getFormInputValue("#assessment-expectation"),
      "context": self.getFormInputValue("#context"),
      "requires_submission": self.checkboxIsChecked("#requires_submission"),
      "submission_types": self.getSubmissionTypes(),
      "framework_criterium_id": self.getFormInputValue("#framework_criterium_criterium_id"),
      "metrics_attributes": metrics_attributes,
      "phases_to_be_deleted": @getSubmissionPhasesInGarbage(),
      "phases_to_be_updated": @getSubmissionPhasesToBeUpdated(),
      "framework_criterium": {
        "framework_id": self.getFormInputValue("#framework_criterium_framework_id"),
        "criterium_id": self.getFormInputValue("#framework_criterium_criterium_id")
      }
    }

    data = {"assessment": assessment}
    return data

  updateTableValue: (selector, content) ->
    self = @
    $("[data-assessment-id=#{self.assessmentId}] #{selector}").html(content)

  updateMetrics: (metrics) ->
    self = @
    content = "<b class='metric-text'>Metrics</b>"

    $(metrics).each (index, object) ->
      content += "<li>#{index} - #{object.description}</li>"

    self.updateTableValue(".metric-list", content)

  updateLearningOutcomeContent: (learningOutcomesApi) ->
    self = @
    learningOutcomesApi.fetchAssessment(self.assessmentId).then (data) ->
      self.updateTableValue(".outcome-data span", data.name)
      self.updateTableValue(".description-data span", data.description)
      self.updateTableValue(".output-data span", data.expectation)
      self.updateTableValue(".framework-data span", data.framework_name)
      self.updateTableValue(".criterium-data span", data.criteria_name)
      self.updateTableValue(".context-data span span", data.context)
      self.updateMetrics(data.metrics)

  refreshLearningOutcomesTable: (
    loadLearningOutcomes,
    includeAdminStatus,
    getSortedOutcomes,
    targetProgramId
  ) =>
    self = @
    targetProgramId ?= @programId
    @paginatingPath = "paginate=true&limit=#{@contentPerPage}&offset=1&return_count=true&#{@yieldSelectedFrameworkAndCriteria()}"
    loadLearningOutcomes.fetchLearningOutcomes(targetProgramId, @paginatingPath).then (data) =>
      @allOutcomes = data
      @populateLearningOutcomesTable(includeAdminStatus(data).assessments)
      @initializePagination(includeAdminStatus(data).assessments, data.count, includeAdminStatus, loadLearningOutcomes)
      
      @handleFrameworkDropdown(
        data.criterium_frameworks,
        includeAdminStatus(data).assessments
      )

      @handleCriteriumDropdown(includeAdminStatus(data).assessments)
      @sortIconListener(getSortedOutcomes)

  submitLearningOutcome: (
    learningOutcomesApi,
  ) ->
    self = @
  
    $("#confirm-submission").click (event) ->
      $(".learning-outcome-form").validate()

      if $(this).attr("class").includes("edit")
        event.preventDefault()
        data = self.getUpdatedData()
        if $(".learning-outcome-form").valid()
          self.loaderUI.show()
          learningOutcomesApi.updateAssessment(self.assessmentId, data)
            .then (response) ->
              if response.message
                self.updateLearningOutcomeContent(
                  learningOutcomesApi
                )

                $('.toast').messageToast.start(response.message, "success")
                self.clearModal()
                self.loaderUI.hide()
                self.modal.close()
                self.flushAllValues()
                self.togglePageScroll('auto')

              else if response.error
                $('.toast').messageToast.start(response.error, "error")
                self.loaderUI.hide()

      else
        event.preventDefault()
        if $(".learning-outcome-form").valid()
          $("#submission_types").val(self.getSubmissionTypes())
          self.loaderUI.show()
          self.modal.close()
          self.flushAllValues()
          self.togglePageScroll('auto')
          $(this).unbind('submit').submit()
 
  ridAllSubmissionPhases: (data) =>
      @submissionPhasesToBeDeleted = @assessmentData.submission_phases if @assessmentData

  flushAllValues: (key, callback) ->
    flushMap =
      submissionPhases: () =>
        callback && callback()
        @assessmentTypes = null
        @selectedPhaseDuration = null
        @selectedPhaseId = null
        $('.multiple-submissions-input-holder:visible').html('')
        $('.multiple-submissions-input-holder:visible').hide('')
        $('.submission-types:visible').hide()
      
      multipleSubmissions: () ->
        callback && callback()
        $('.submission-types').hide()
        $('.multiple-submissions-input-holder:visible').html('')
        $('.multiple-submissions-input-holder:visible').hide()
        $('.assessment-phases-dropdown').hide()
  
      requiresSubmission: () ->
        callback && callback()
        $('#multiple_submissions').val('None')
        $('.multiple-submissions-holder').hide()
        $('#submission-phase-id').val('None')
        $('.assessment-phases-dropdown').addClass('hidden')
        $('.multiple-submissions-input-holder').html('')
        $('.multiple-submissions-input-holder').hide('')
        $('.submission-types:visible').hide()

      clearInitializingValues: () =>
        @assessmentData = null
        @submissionPhasesToBeDeleted = null
        @phasesSpecified = null
        @phasesToBeDeleted = null
        @toBeUpdated = null

    return flushMap[key]() if key and flushMap[key]
    #flush all if there is no key specified key
    #We might want to do this when the modal is closed
    #be careful not so flush @allOutcomes because this is
    # set only when the page loads
    ((func) -> func()) flush for flush in Object.values(flushMap)
    
  yieldSelectedFrameworkAndCriteria: ->
    yieldValid = (key, value) ->
       return "" if value == "All"
       "#{key}=#{value}"
     frameworkId = $('.framework-filter-outcome').val()
     criteriumName = $('#criteria-filter-outcome').val()
     "#{yieldValid("framework_id", frameworkId)}&#{yieldValid("criterium_name", criteriumName)}"

    