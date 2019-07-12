class LearnersDashboard.UI
  constructor: ->
    @modal = new Modal.App('#modal', 525, 525, 525, 525)
    @dropdownDecision = new Modal.App('#decision-select')
    @mainSection = $(document)

  handleCloseDecisionUpdateModal: =>
    self = @
    $('.close-button, .cancel, .ui-widget-overlay').click ->
      $("#decision-status-error").html("")
      $("#decision-reason-error").html("")
      self.closeDecisionUpdateModal()

  closeDecisionUpdateModal: =>
    self = @
    self.modal.close()

  openDecisionModal: ->
    self = @
    self.modal.open()

  changeLearnerStatus: (
    decisionItem = $('.decision-item'),
    getDecisionReason,
    getDecisionDetail
  ) ->
    self = @
    decisionItem.click ->
      self.openDecisionModal()
      self.updateCommentValue('textarea.leave-comment', "")

      name = $(@).parent().data 'learner'
      $('#learner-name').val(name)
      stage = $(@).attr('id').split('-', 1)[0].split('_', 3)[2]
      learnerDecisionStatus = $(@).data 'val'

      camperData = $(@).attr 'id'
      initialDecision = $(@).data('initial-decision')
      dataIndex = camperData.split('status_-')[1].split('_s')[0] + "-" + camperData.split('status_-')[1].slice(camperData.split('status_-')[1].lastIndexOf("_") + 1)
      learnerProgramId = dataIndex.split("-")[dataIndex.split("-").length - 1]
      camperId = camperData.split("-")[1].replace(/(_status_)/g, "")
      decisionStatusId = "decision-status-#{stage}--#{dataIndex}"

      # get the stage and learnerProgramId by spliting the id value of the element
      $(".stage-learner-id").attr("id", "#{stage}-#{learnerProgramId}")

      # get decisionStatus from this id set on the modal
      $(".decision-info").attr("id", decisionStatusId)

      self.dropdownDecision.initializeDropdown()

      $('#decision-select').val(learnerDecisionStatus.trim()).selectmenu("refresh")
      self.dropdownToggleIcon('decision')

      # populate decision reason dropdowns on modal open
      self.populateDecisionReason(learnerDecisionStatus, getDecisionReason)

      # populate decision comment fields on modal open
      self.populateDecisionComment(stage, learnerProgramId, getDecisionDetail, true)

  # saveLearnersDecisionDetails
  handleOnClickSaveDecision: (saveLearnersDecisionDetails) =>
    self = @
    $('.decision-button .save').on 'click', (event) ->
      
      decisionStatusElementId = $(".decision-info").attr("id")
      learnerProgramDetail = $(".stage-learner-id").attr("id")
      stage = learnerProgramDetail.split('-')[0]
      learnerProgramId = learnerProgramDetail.split('-')[1]
      learnerDecisionStatus = $('#decision-select').val()
      learnerDecisionReasons = $('#decision-reason-select').val()
      learnerDecisionComment = $('.comment .leave-comment').val()

      # prepare decision status
      decisionStage = if stage == 'two' then 2 else 1
      if decisionStage == 2
        status = { decision_two: learnerDecisionStatus.trim() }
      else
        status = { decision_one: learnerDecisionStatus.trim() }

      decisionData = {
        decisions: {
          stage: decisionStage,
          learner_program_id: learnerProgramId,
          reasons: learnerDecisionReasons,
          comment: learnerDecisionComment
        }
      }
      saveLearnersDecisionDetails(
        learnerDecisionStatus,
        status,
        learnerProgramId,
        decisionData,
        decisionStatusElementId
      )

  clickColumnFilterList: ->
    $('.column-filter-wrapper li').on 'click', (event) ->
      event.stopPropagation()

  dropdownToggleIcon: (selector) ->
    $(".#{selector}-select").on "selectmenuopen", (event, ui) ->
      $(".#{selector}").find('.ui-icon').addClass('ui-icon-up')
    $(".#{selector}-select").on "selectmenuselect", (event, ui) ->
      $(".#{selector}").find('.ui-icon').removeClass('ui-icon-up')
    $(".#{selector}-select").on "selectmenuclose", (event, ui) ->
      $(".#{selector}").find('.ui-icon').removeClass('ui-icon-up')

  setElementHeight: (selector, bottomMargin) =>
    $(selector).css({
      height: $(window).height() - bottomMargin
      minHeight: $(window).height() - bottomMargin
      maxHeight: $(window).height() - bottomMargin
    })
  
  setDefaultMainContentHeight: ->
    self = @
    if $(window).width() > 890
      $('.main-content').css('margin-top', '100px')
      self.setElementHeight('.main-content', 205)
    else
      $('.main-content').css('margin-top', '0')
      self.setElementHeight('.main-content', 140)

  setFilterBoxStyles: ->
    self = @
    $('.mdl-menu__container').removeClass('is-visible')
    filterBtnLeft = $('.filter-btn').offset().left
    $('.parent-dropdown').css('max-height', $(window).height() - 300)
    if (filterBtnLeft < $('.parent-dropdown').width())
      $('.mdl-menu__container').removeClass('filter-box-lg-pos').addClass('filter-box-sm-pos')
    else
      $('.mdl-menu__container').removeClass('filter-box-sm-pos').addClass('filter-box-lg-pos')

  setDefaultTableHeight: ->
    self = @
    if $(window).width() > 890
      self.setElementHeight('.learners-page-pane-vScroll', 367)    
    else
      self.setElementHeight('.learners-page-pane-vScroll', 330)

  setTableHeightOnScroll: ->
    self = @
    if $(window).width() > 890
      self.setElementHeight('.learners-page-pane-vScroll', 257)
    else
      self.setElementHeight('.learners-page-pane-vScroll', 190)

  setDefaultStyles: ->
    $('html, body').addClass('learners-page-parents')
    $('.main-content').addClass('learners-page-main-section')
    $('.mdl-mini-footer').addClass('learners-page-footer')
    $('.top-section').addClass('learners-page-top-section')
    $('.pane-hScroll').addClass('learners-page-pane-hScroll')
    $('.pane-vScroll').addClass('learners-page-pane-vScroll')
    $('.u-topSpacing').css({
      height: '1px',
      overflow: 'hidden'
    })

  fixTableHeaderScroll: ->
    $('.pane-vScroll').width $('.pane-hScroll').width() + $('.pane-hScroll').scrollLeft()
    thead = document.querySelector('.pane-hScroll thead')
    if thead
      theadChildren = thead.querySelector('tr').children
      theadChildren[0].style.width = '2.3rem'

  onPageResize: ->
    self = @
    $(window).resize -> 
      self.setDefaultStyles()
      self.setDefaultTableHeight()
      self.setDefaultMainContentHeight()
      self.setFilterBoxStyles()
      self.fixTableHeaderScroll()

  onTableScroll: ->
    self = @
    $('.pane-hScroll').scroll ->
      self.fixTableHeaderScroll()

    $('.pane-vScroll').scroll ->
      if $(this).scrollTop() == 0
        $('.top-section').show()
        self.setDefaultTableHeight()
      else
        $('.top-section').hide()
        self.setTableHeightOnScroll()

  onPageLoad: ->
    self = @
    self.setDefaultStyles()
    self.setDefaultTableHeight()
    self.setDefaultMainContentHeight()
    self.fixTableHeaderScroll()
    self.setFilterBoxStyles()

  # Close dropdown menu via arrow-down icon
  # Implementaion by mdl-js caters for opening and closing dropdown
  # by clicking dropdown text but not closing by arrow-down icon
  # More work on this could be done to make sure only mdl-js handles dropdown actions
  closeDecisionAndLFADropdownsByIcon: ->
    self = @
    dropdownIcons = $("td > div > label > i")

    dropdownIcons.on 'click', (event) ->
      event.stopPropagation()
      currentDropDownIcon = $(this)
      currentDropDownMenu = currentDropDownIcon.closest('.mdl-textfield').find('ul')
      currentDropDownMenu.attr('style', '')

  # download csv
  downloadCSV: ->
    self = @
    $('a.export-btn').on 'click', (event) ->
      event.preventDefault()
      if localStorage.getItem('filterOptions')
        options = JSON.parse(localStorage.getItem("filterOptions"))
      else
        options = JSON.parse(localStorage.getItem("defaultOptions"))
      url = """
            #{window.location.protocol}//#{window.location.host}/sheet?
            format=csv&program_id=#{options.program_id}&city=#{options.city}&cycle=#{options.cycle}
            &decision_one=#{options.decision_one}&decision_two=#{options.decision_two}
            &week_one_lfa=#{options.week_one_lfa}&week_two_lfa=#{options.week_two_lfa}
            """
      window.location.href = url

  clearErrorText: (elementId) ->
    $(elementId).html("")
  
  displayErrorText: (elementId, message) ->
    $(elementId).html(message)
  
  toggleActiveDropdown: (elementId, options, status) ->
    if status == "disable"
      $(elementId).removeAttr("disabled").html(options)
    else
      $(elementId).attr("disabled", "disabled").html(options)
  
  updateCommentValue: (elementId, comment="") ->
    $(elementId).val(comment)

  changeDecisionStatus: (getDecisionReason, getDecisionDetail) ->
    self = @
    $('#decision-select').on 'selectmenuchange', (event) ->
      learnerDecisionStatus = $('#decision-select').val()
      self.populateDecisionReason(learnerDecisionStatus, getDecisionReason)

      learnerProgramDetail = $(".stage-learner-id").attr("id")
      stage = learnerProgramDetail.split('-')[0]
      learnerProgramId = learnerProgramDetail.split('-')[1]
      self.populateDecisionComment(stage, learnerProgramId, getDecisionDetail)
  
  # get decision reasons for a given selected status
  populateDecisionReason: (status, getDecisionReason) =>
    self = @
    if status != "In Progress" and Boolean(status)
      getDecisionReason(status).then(
        (decisionReasons) ->
          # prepare options and update select field
          if decisionReasons
            options = "<option selected='selected'>Select Reasons</option>"
            $.each(decisionReasons, (index, decisionReason) =>
              options += "<option value='#{decisionReason}'>#{decisionReason}</option>"
            )
            self.toggleActiveDropdown('#decision-reason-select', options, 'disable')
            self.dropdownToggleIcon('decision-reason')
          else
            options = "<option selected='selected'>N/A</option>"
            self.toggleActiveDropdown('#decision-reason-select', options, 'enable')
      )
    else
      options = "<option selected='selected'>N/A</option>"
      self.toggleActiveDropdown('#decision-reason-select', options, 'enable')

  # get decision reasons and comments for a given learner
  populateDecisionComment: (stage = "one", learnerProgramId, getDecisionDetail, updateComment = false) =>
    self = @
    decisionStage = if stage == 'two' then 2 else 1
    getDecisionDetail(learnerProgramId).then(
      (response) ->
        if response.length > 0
          $.each(response, (index, recordedReason) ->
            if decisionStage is recordedReason.stage
              if recordedReason.details['Comment'] and updateComment
                self.updateCommentValue('textarea.leave-comment', recordedReason.details['Comment'])
              self.highlightDecisionReason('select.decision-reason-select option', recordedReason)
          )
      (error) ->
        self.updateCommentValue('textarea.leave-comment', "")
    )

  saveDecisionToast: (saveResponse) ->
    self = @
    if saveResponse.message
      $('.toast').messageToast.start(saveResponse.message, 'success')
    else
      $('.toast').messageToast.start(saveResponse.error, 'error')
    return

  highlightDecisionReason: (elementId, recordedReason) ->
    decision = $('select.decision-select').val()
    if decision == recordedReason.details['Decision']
      reasons = recordedReason.details['Reasons'].split(", ")
      $(elementId).each (index, element) ->
        if $(element).val() is 'Select Reasons'
          $(element).removeAttr('selected')
        else if reasons.includes($(element).val())
          $(element).attr('selected', 'selected')
    return

  getLearnerId: (element) =>
    return element.id.split("-")[4...].join("-")

  updateDecisionsDropdown: () ->
    self = @
    decisionOneSelections = $('#campers-table-records .decision-one .decision-status-input')
    decisionTwoSelections = $('#campers-table-records .decision-two .decision-status-input')
    $.each(decisionOneSelections, (index, decisionOneSelection) ->
      decision1Value = decisionOneSelection.value
      camperDataId = self.getLearnerId(decisionOneSelection)
      if decision1Value
        decisionTwoSelection = decisionTwoSelections.filter((index) ->
          return $(this).attr('id') == "decision-status-two--#{camperDataId}"
        )[0]
        if $(decisionOneSelection).attr('disabled') == 'disabled' || decision1Value.trim() !in ['Advanced', 'Fast-tracked']
          $(decisionTwoSelection).attr('disabled','disabled').val('Not Applicable').css('color', '#b9b9b9')
          $("#lfa-week-2--#{camperDataId}").attr('disabled', 'disabled').val('Unassigned').css('color', '#b9b9b9')
        else
          $(decisionTwoSelection).removeAttr('disabled').val('In Progress').css('color', '#000')
          $("#lfa-week-2--#{camperDataId}").removeAttr('disabled').css('color', '#000')
          return
    )
  
  updateStatusColor: (status, decisionData) ->
    self = @
    currentStatus = status['decision_two'] || status['decision_one']   
    switch currentStatus
      when 'Rejected' then $("#learner_status_#{decisionData.decisions['learner_program_id']}").css('background-color', '#f57474')
      when 'Dropped Out' then $("#learner_status_#{decisionData.decisions['learner_program_id']}").css('background-color', '#000')
      when 'Accepted' then $("#learner_status_#{decisionData.decisions['learner_program_id']}").css('background-color', '#00b803')
      when 'Level Up' then $("#learner_status_#{decisionData.decisions['learner_program_id']}").css('background-color', '#ffaf30')
      when 'Advanced' then $("#learner_status_#{decisionData.decisions['learner_program_id']}").css('background-color', '#3359db')
      else $("#learner_status_#{decisionData.decisions['learner_program_id']}").css('background-color', '#bbb')
      
