class HolisticPerformanceHistory.UI
  constructor: ->
    @modal = new Modal.App('#holistic-performance-history', 930, 930, 930, 625)
    @accordion = new Accordion.App()
    @emptyState = new EmptyState.UI()
    @truncateText = new TruncateText.UI()
    @loaderUI = new Loader.UI()
    @viewHolisticContent = []
    @editHolisticContent = []
    @holisticEvaluation = []
    @errors = []


  viewHistory: (getHolisticHistory) =>
    self = @
    $(document).on 'click', '#holistic-performance, .holistic-avg', (event) =>
      if event.target.id == 'holistic-performance'
        self.learnerProgramId = location.pathname.split('/')[3]
        getHolisticHistory(self.learnerProgramId)
      else
        self.learnerProgramId = $(event.target).data('learner-program-id')
        getHolisticHistory($(event.target).data('learnerProgramId'))
        $('#holistic-perfomance-history-modal-bottom').removeClass('modal-bottom')
        $('#holistic-perfomance-history-modal-bottom').css('display', 'none')
        $('.holistic-evaluation-top-header').css('display', 'block')

      $('#learner-feedback-modal').css("display", "none")
      window.scrollTo(0, 0)
      self.modal.open()
      self.loaderUI.show()
      activeAccordion = $('.mask.accordion-section-title.active')
      $('#holistic-performance-evaluation').css('display', 'none')
      $('.ui-dialog').css('padding', 0)

    $('.close-holistic-modal, .ui-widget-overlay, a.close-scores').click ->
      self.modal.close()
      $('#holistic-history-modal-content').html ''
      $('#holistic-performance-evaluation').css('display', 'block')

  canEditScores: (canEditScores) ->
    if canEditScores
      $(".edit-holistic-evaluation-btn").show()
    else
      $(".edit-holistic-evaluation-btn").hide()

  viewScores: (key, details, index) ->
    comment = @truncateText.generateContent(details.comment, maximumLength=70)
    "<div class='holistic-criteria-div'>
      <div class='holistic-criteria-wrapper'>
        <span class='column-criteria'>#{key}: #{details.score}</span>
        <span class='column-comment expand-comment grey-out'>#{comment.html()}</span>
      </div>
    </div>"

  editScores: (index, key, details) ->
    scores = [-2, -1, 0, 1, 2]
    scoreText = [
      'Very Unsatisfied (-2)',
      'Unsatisfied (-1)',
      'Neutral (0)',
      'Satisfied (1)',
      'Very Satisfied (2)',
    ]
    options = ''

    for score, index in scores
      options += "<option value='#{score}' #{if score == details.score then 'selected' else ''}>#{scoreText[index]}</option>"

    "<div class='holistic-criteria-div'>
      <div class='edit-scores'>
         <div class='criterium-card #{key}'>
           <div class='criterium-box'>
             <div class='criterium-header'>
             <span id='#{details.criterium_id}'>#{key}</span>
             <span id='criterion-#{details.criterium_id}' class='material-icons information-icon'> info_outline </span>
             <span class='holistic-evaluation-id' id='#{details.id}'></span>
           </div>
           </div>
           <div class='select-background'>
              <select name='scores' id='satisfaction-level-select' class='satisfaction-level'>
                #{options}
              </select>
           </div>
           <div class='comment-area'>
         <textarea class='leave-comment'>#{details.comment}</textarea>
        </div>
        </div>
      </div>
    </div>"

  populateHolisticContent: (index, evaluation, collapsibleBodyItem) ->
    "<div id='accordion-title-#{index}' class='mask accordion-section-title' href='#accordion-#{index}'>
          <span class='chevron-down-circle'></span><span class='chevron-right-circle'></span>
          <span>
            <span class='holistic-date'>
              <span class='holistic-evaluation-date'>#{evaluation.created_at.date}</span>
              <span class='holistic-evaluation-time'>#{evaluation.created_at.time}</span>
            </span>
            <span class='average-assessment grey-out'>
              AVG: #{evaluation.average}
            </span>
        </div>
        <div id='accordion-#{index}' class='accordion-section-content'>
        <span id='edit-evaluation-#{index}' class='edit-holistic-evaluation-btn'></span>
          <div class='holistic-div-row'>" + collapsibleBodyItem +
    " </div>
    </div>"

  editHolisticScores: (collapsibleBodyItemEdit, index) ->

    "<div class='holistic-div-edit'>" + collapsibleBodyItemEdit + "</div>
                   <div class='buttons'>
                     <a id='save-edit-#{index}' class='btns save-updates-btn'>Save</a>
                     <a id='btn-cancel-#{index}' class='cancel-btn edit-holistic-cancel-btn'>Cancel</a>
                    </div>"

  populateScoresHistoryModal: (data, updateHolisticEvaluation) ->
    historyDetails = data.holistic_evaluation_details

    $('#holistic-history-modal-content').html ''
    content = ""
    @editHolisticContent = []
    @viewHolisticContent = []

    if (!historyDetails)
      @loaderUI.hide()
      return $('#holistic-history-modal-content').append @emptyState.getNoContentText()

    for index, evaluation of historyDetails
      collapsibleBodyItem = ''
      collapsibleBodyItemEdit = ''

      for key, details of evaluation.details
        collapsibleBodyItem += @viewScores(key, details, index)
        collapsibleBodyItemEdit += @editScores(index, key, details)

      content += @populateHolisticContent(index, evaluation, collapsibleBodyItem)
      @clickEditHolisticScores(index)
      @clickCancelEditMode(content, index)
      @clickSaveHolisticEvaluationButton(updateHolisticEvaluation, content, index)

      @editHolisticContent.push(@editHolisticScores(collapsibleBodyItemEdit,index))
      @viewHolisticContent.push("<div id='accordion-#{index}' class='accordion-section-content'>
        <span id='edit-evaluation-#{index}' class='edit-holistic-evaluation-btn'></span>
          <div class='holistic-div-row'>" + collapsibleBodyItem +
        " </div>")

    @accordionAction(content)
    @canEditScores(data.can_edit_scores)
    @truncateText.activateShowMore(historyDetails, false)
    @loaderUI.hide()

  clickEditHolisticScores: (index) ->
    self = @
    $(document).on 'click', '#edit-evaluation-'.concat(index), (event) ->
      event.preventDefault()
      $('#accordion-'.concat(index)).html(self.editHolisticContent[index])
      $('.satisfaction-level').selectmenu()
      self.checkScoreValue()

  clickCancelEditMode: (content, index) ->
    self = @
    $(document).on 'click', '#btn-cancel-'.concat(index), (event) ->
      event.preventDefault()
      $('#accordion-'+index).replaceWith self.viewHolisticContent[index]
      self.truncateCommentText()

  checkScoreValue: () ->
    holisticScore = $('.satisfaction-level')
    holisticScore.on('blur', (event) =>
      $(event.currentTarget).val(-2) if event.currentTarget.value < -2
      $(event.currentTarget).val(2) if event.currentTarget.value > 2
    )


  validateFields: (evaluationData, checkSpaces) ->
    error = ''
    if not evaluationData.score
      error = 'no score'
    else if evaluationData.score in ["-2", "-1", "2"] && (
      not evaluationData.comment || checkSpaces)
      error = 'no comment'
    return error

  getModifiedHolisticEvaluationDetails: (validateFields) ->
    self = @
    self.holisticEvaluation = []
    self.errors = []
    $('div.holistic-div-edit > div.holistic-criteria-div').each () ->
      criteriumId = $(this).find('.criterium-header').find('span').attr('id')
      comment = $(this).find('textarea').val()
      score = $(this).find('select').val()
      id = parseInt($(this).find('.holistic-evaluation-id').attr('id'))
      checkSpaces = $.trim(comment).length == 0
      evaluationData = {
        id,
        criteriumId,
        comment,
        score
      }
      error = self.validateFields(evaluationData, checkSpaces)
      if error == ''
        self.holisticEvaluation.push({ id: id, criterium_id: criteriumId, score: score, comment: comment })
      else
        self.errors.push(error)
    self.holisticEvaluation

  afterUpdate: (data) =>
    if data.status is true
      $('.toast').messageToast.start('Holistic evaluation successfully updated', 'success')
      @closeModal()
    else if data.status is 401
      $('.toast').messageToast.start('You do not have authorization to edit these scores', 'error')
    else
      $('.toast').messageToast.start('Failed to edit the scores', 'error')


  closeModal: =>
    @modal.close()
    $(".ui-widget-overlay").hide()

  clickSaveHolisticEvaluationButton: (updateHolisticEvaluation, content='', index=0) ->
    self = @
    $(document).on 'click', '#save-edit-'.concat(index), (event) ->
      event.stopImmediatePropagation()
      self.getModifiedHolisticEvaluationDetails()
      self.checkBlankFields()
      if self.errors.length
        self.errors = []
      else
        updateHolisticEvaluation(self.holisticEvaluation, self.afterUpdate, self.learnerProgramId)

  checkBlankFields: =>
    if @errors.length
      @flashErrorMessage(@errors[@errors.length-1])

  flashErrorMessage: (@error) =>
    if @error is 'no score'
      $('.toast').messageToast.start('Please select a Satisfaction Level for all fields', 'error')
    else if @error is 'no comment'
      $('.toast').messageToast.start('Please add valid comments to all mandatory fields', 'error')

  accordionAction: (content) =>
    $('#holistic-history-modal-content').hide()
    $('#holistic-history-modal-content').html content
    @accordion.start()
    $('#holistic-history-modal-content').show()

  downloadHolisticEvaluationCSV: (holisticHistory)->
    $(".scores-history-export-btn").off()
    $(".scores-history-export-btn").click () ->
      if holisticHistory
        learnerProgramId = location.pathname.split('/')[3]
        camperId = location.pathname.split('/')[2]
        url = """
          #{window.location.protocol}//#{window.location.host}/
          holistic-csv/#{learnerProgramId}?format=csv&camper_id=#{camperId}
          """
        window.location.href = url
      else
        $('.toast').messageToast.start("No data to export", "error")
