class Curriculum.UI
  constructor: ->
    @api = new Curriculum.API()
    @emptyState = new EmptyState.UI()
    @helpers = new Helpers.UI()
    @programId = localStorage.getItem('programId')
    @modal = new Modal.App(".add-criterion-modal", 500, 500, "auto", "auto")
    @editModal = new Modal.App(".edit-criterion-modal", 500, 500, "auto", "auto")
    @deleteCriterionModal = new Modal.App('#archive-criteria-modal', 500, 500, 255, 255)
    @loaderUI = new Loader.UI()
    @truncateText = new TruncateText.UI()

  metricsList: (criteriumId) ->
    sortedPoints = @helpers.sortHash(@currentData.points)
    sortedPoints = @helpers.objectToArray(sortedPoints)
    criteriumMetrics = @currentData.metrics.filter ((metric) ->
      metric.criteria_id == criteriumId
    )
    criteriumMetrics.map ((metric) ->
      point = sortedPoints.find((point) -> point.id == metric.point_id)
      {metric, point}
    )

  populateCriteriumRow: (criterium, options, metricstList, actionColumn) ->
    context = @truncateText.generateContent(criterium.context).html()
    criteriaMetrics = metricstList.map(
      (m) => "#{m.point.value} - #{m.point.context} #{m.metric.description}"
    ).join("\n")
    criteriaMetrics = @truncateText.generateContent(criteriaMetrics).html()
    "<tr id='criterion-row-#{criterium.id}' class='criteria-row-wrapper'>
      <td class='align-up criteria-criterion'> <span>#{criterium.name}</span></td>
      <td class='align-up criteria-framework'>#{options}</td>
      <td class='align-up criteria-context'>
        <b class='context-text bold-text'>Context</b>
        <br>
        <span>#{context || 'No context'}</span>
        <br>
        <ul class='metric-list'>
          <b class='metric-text bold-text metric-margin'>Metrics</b>
          <div class='list-margin'><li>#{criteriaMetrics || 'No metrics'}</li></div>
        </ul>
      </td>
      <td class='align-up criteria-description'>
          <span>
          #{criterium.description || 'N/A'}
      </span>
      </td>
      #{actionColumn}
    </tr>"

  populateCriteriaTable: (filteredCriteria, passedInData) ->
    if filteredCriteria.length == 0
      @api.fetchCurriculumDetails(@programId).then (data) ->
        if data['criteria'].length == 0
          $(".framework-filter").hide()
          $(".no-search-result").remove()
          $(".criteria-header-table").hide()
          $(".no-criteria").append """
            <h5 class='no-search-result'>No data to show :(</h5>
          """
        else
          $(".no-search-result").remove()
          $(".criteria-table").hide()
          $(".criteria-header-table").hide()
          $(".no-criteria").append """
            <h5 class='no-search-result'>We couldn't find any results :(</h5>
          """

    else if filteredCriteria.length > 0
      $("#criteria-body").html ''
      @allCriteria = filteredCriteria
      @currentData = passedInData
      for key, criterium of filteredCriteria
          options = ""

          for index, framework of criterium.frameworks
              options +="<span>#{framework.name}</span><br class='framework-name__break'>"

          metric_list = @metricsList(criterium.id)

          if passedInData.is_admin is true
            actionColumn = "<td class='align-up criteria-action'>
              <span id='edit-criteria-#{criterium.id}' class='edit-icon'></span>
              <span id='delete-criteria-#{criterium.id}' class='archive-icon'>
              <i class='fa fa-archive fa-2x' aria-hidden='true'></i>
              </span>
            </td>"
          else
            actionColumn = ""

          currentCriteriumRow = @populateCriteriumRow(criterium, options, metric_list, actionColumn)

          $(".no-search-result").hide()
          $("#criteria-body").append currentCriteriumRow
          $(".criteria-table").show()
          $(".criteria-header-table").show()
      @truncateText.activateShowMore()
    else
      $(".no-search-result").remove()
      $(".criteria-table").hide()
      $(".criteria-header-table").hide()
      $(".no-criteria").append """
        <h5 class='no-search-result'>We couldn't find any results :(</h5>
      """

  sortOrderIcon: (orderBy, elementClicked) ->
    if orderBy == -1
      elementClicked.removeClass('sort-icon-asc').addClass('sort-icon-desc')
    else
      elementClicked.removeClass('sort-icon-desc').addClass('sort-icon-asc')

  sortIconListener: (sortCriteriaTable) =>
    self = @
    $(".sort-icon").on 'click', (event) ->
      sortField = $(this).context.dataset.field
      sortName = 'criteria'

      orderBy = if $(this).css('background-image').includes('a-z') then -1 else 1

      sortCriteriaTable(self.criteriaDetails, orderBy, sortField, $(this))

  criteriaFilterListener: (filterCriteriaByFramework) =>
    self = @
    $('select').on 'selectmenuchange', (error, target) ->
      value = Number(target.item.value)
      filterCriteriaByFramework value;

  addCriteriaListener: =>
    self = @
    $(".add-criterion-btn").on "click", () ->
      window.scrollTo(0, 0)
      self.modal.open()
      $('body').css('overflow', 'hidden')

      $('.add-criterion-cancel, .close-button').click ->
        self.clearCriteriaForm()
        self.modal.close()
        $('#add-learner-outcome').css('display', 'none')
        $('body').css('overflow', 'auto')

      $('.ui-widget-overlay').click ->
        self.modal.close()
        $('#add-learner-outcome').css('display', 'none')
        $('body').css('overflow', 'auto')

  clearCriteriaForm: =>
    $("#criterium_name").val("")
    $("#criterium_description").val("")
    $(".mdl-js-checkbox").each (index, element) ->
      element.MaterialCheckbox.uncheck()

  openEditCriteriaModal: =>
    @editModal.open()
    @editModal.setHeaderTitle('.edit-criterion-header', 'Edit Criterion')
    $('body').css('overflow', 'hidden')

  closeEditCriteriaModal: =>
    @editModal.close()
    @clearEditModal()
    $('body').css('overflow', 'auto')

  editCriteriaListener: =>
    self = @
    $("#criteria-body").on 'click', 'span.edit-icon', ->
      self.openEditCriteriaModal()
      criterionId = Number($(this).attr("id").split("-")[2])
      self.populateEditModal(criterionId)

      $('.edit-criterion-cancel, .close-button').click ->
        self.closeEditCriteriaModal()

  clearEditModal: ->
    $('.edit-framework').each (index, element) =>
      if $(element).parents().hasClass('is-checked')
        $(element).click()
    $("#criterium_edit_very_satisfied").val('')
    $("#criterium_edit_satisfied").val('')
    $("#criterium_edit_neutral").val('')
    $("#criterium_edit_unsatisfied").val('')
    $("#criterium_edit_very_unsatisfied").val('')

  populateEditModal: (criterionId) =>
    selectedCriteria = (criteria for criteria in @allCriteria when criteria.id == criterionId)[0]
    selectedMetrics = (metric for metric in @currentData.metrics when metric.criteria_id == criterionId)
    $("#criterium_edit_id").val(selectedCriteria.id)
    $("#criterium_edit_name").val(selectedCriteria.name)
    $("#criterium_edit_description").val(selectedCriteria.description)
    $("#criterium_edit_context").val(selectedCriteria.context)
    $(".mdl-js-checkbox").each (index, element) ->
      element.MaterialCheckbox.uncheck()

    for index, framework of selectedCriteria.frameworks
      $("#edit-"+framework.id).click()

    metricSelectors = {
      5: "#criterium_edit_very_satisfied",
      6: "#criterium_edit_satisfied",
      7: "#criterium_edit_neutral",
      8: "#criterium_edit_unsatisfied",
      9: "#criterium_edit_very_unsatisfied"
    }

    for key, metric of selectedMetrics
      $(metricSelectors[metric.point_id]).val(metric.description)

  updateClickedFramework: =>
    $('.edit-framework').click ->
      @clickedFramework = $(this).attr("id").split("-")[1]
      $('#frameworkids').val(@clickedFramework)

  getUpdatedData: =>
    if $('#edit-framework-form').valid()
      id = $("#criterium_edit_id").val()
      name = $("#criterium_edit_name").val()
      description = $("#criterium_edit_description").val()
      context = $("#criterium_edit_context").val()
      verySatisfied = $("#criterium_edit_very_satisfied").val()
      satisfied = $("#criterium_edit_satisfied").val()
      neutral = $("#criterium_edit_neutral").val()
      unsatisfied = $("#criterium_edit_unsatisfied").val()
      veryUnsatisfied = $("#criterium_edit_very_unsatisfied").val()
      frameworkIds = $("#frameworkids").val()

      details = {
        "criterium": {
          "name": name,
          "description": description,
          "context": context,
          "metrics": {
              "5": verySatisfied,
              "6": satisfied,
              "7": neutral,
              "8": unsatisfied,
              "9": veryUnsatisfied}},
        "frameworks": [frameworkIds]
      }
    return {"id": id, "details": details}

  submitEditCriteriaForm: (updateCriteria) ->
    self = @
    $('.edit-criterion-save').click =>
      id = self.getUpdatedData().id
      details = self.getUpdatedData().details

      self.loaderUI.show()
      updateCriteria(id, details)

  showToastNotification: (message, status) ->
    $('.toast').messageToast.start(message, status)

  criteriaCheckboxListener: =>
    $(".edit-criteria-checkbox__input").on "click", () ->
      $(".edit-criteria-checkbox__input").not(this).each (index, element) ->
        element.parentElement.MaterialCheckbox.uncheck()

  populateSwitchingTabs: (criteriaLength, program, frameworksLength) ->
    $('span#criteria').html(criteriaLength)
    $('span#frameworks-length').html(frameworksLength)
    $('span#program').html(program)

  searchHeader: (result) ->
    text = "#{result} result"
    text = text + 's' unless result is 1
    $('#search-length').html text

  submitCriteria: ->
    self = @
    $(".add-criterion-save").click ->
      $(".add-criterion-form").validate()
      if $(".add-criterion-form").valid()
        self.loaderUI.show()

  disableSwitchingTabs: (tabClass) ->
    $(tabClass).addClass('disable')

  enableIsActiveOnSwitchingTabs: (tabClass) ->
    $(tabClass).addClass('is-active')

  disableIsActiveOnSwitchingTabs: (tabClass) ->
    $(tabClass).removeClass('is-active')

  disableEmptyTabs: (criteriaLength, outcomeLength) ->
    self = @
    criteriaTab = $('.criteria-tab')
    criteriaPanel = $('.criteria-panel')
    outcomeTab = $('.learning-outcome-tab')
    outcomePanel = $('.learning-outcome-panel')

    if criteriaLength == 0 and outcomeLength >= 1
      self.disableSwitchingTabs(criteriaTab)
      self.disableIsActiveOnSwitchingTabs(criteriaTab)
      self.enableIsActiveOnSwitchingTabs(outcomeTab)
      self.enableIsActiveOnSwitchingTabs(outcomePanel)
    else if criteriaLength == 0
      self.disableSwitchingTabs(criteriaTab)
      self.enableIsActiveOnSwitchingTabs(criteriaPanel)
    else
      self.enableIsActiveOnSwitchingTabs(criteriaTab)
      self.enableIsActiveOnSwitchingTabs(criteriaPanel)

  deleteCriteriaModal: (deleteCriterion) ->
    self = @
    $('#criteria-body').on 'click', 'span.archive-icon', ->
      self.deleteCriterionModal.open()
      self.criterionId = Number($(this).attr("id").split("-")[2])
      self.cancelDelete()
    $('#confirm-delete-criteria').click (event) ->
      event.preventDefault()
      deleteCriterion(self.criterionId)

   cancelDelete: ->
    self = @
    $('div#archive-criteria-modal').find('a.btn-cancel, .btn-cancel').click (event) ->
      self.deleteCriterionModal.close()
