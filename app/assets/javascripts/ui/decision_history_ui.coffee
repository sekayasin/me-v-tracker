class DecisionHistory.UI
  constructor: ->
    @modal = new Modal.App('.decision-history-modal', 850, 930, 513, 513)
    @accordion = new Accordion.App()
    @emptyState = new EmptyState.UI()

  view: (getDecisionHistory) =>
    self = @

    $('.view-decision-history').click =>
      getDecisionHistory()
      
      $('#learner-feedback-modal').css("display", "none")
      window.scrollTo(0, 0)
      self.modal.open()
      $('body').css('overflow', 'hidden')
      $('.ui-dialog').css('padding', 0)

      $('.close-button, .ui-widget-overlay, .close-decision-history').click ->
        self.modal.close()
        $('body').css('overflow', 'auto')

  populateDecisionHistoryModal: (decisionHistory) =>
    $('#decision-history-modal-content').html ''
    content = ""
    
    if (decisionHistory.length < 1)
      return $('#decision-history-modal-content').append @emptyState.getNoContentText()

    for index, decision of decisionHistory
      collapsibleBodyItem = ''

      for key, detail of decision.details
        collapsibleBodyItem += "<div class='decision-detail-div'>
          <div class='decision-detail-wrapper'>
            <span class='column-detail-name'>
              #{@structureKeyNames(key, decision.multiple_reasons)}
            </span>
            <span class='column-detail-value expand-comment grey-out'>
              #{@handleEmptyState(key, detail)}
            </span>
          </div>
        </div>"

      content += "<div class='mask accordion-section-title' href='#accordion-#{index}'> 
        <span class='chevron-down-circle'></span><span class='chevron-right-circle'></span>
        <span> 
          <span class='decision-history-datestamp'>
            <span class='decision-date'>#{decision.created_at.date}</span>
            <span class='decision-time'>#{decision.created_at.time}</span>
            <span class='decision-stage-text'>- Decision #{decision.stage}</span>
          </span>
        </span>
      </div>
      <div id='accordion-#{index}' class='accordion-section-content'>
        <div class='decision-div-row'>" + collapsibleBodyItem +
      " </div>
      </div>"

    $('#decision-history-modal-content').hide()
    $('#decision-history-modal-content').html content
    @accordion.start()
    $('#decision-history-modal-content').show()

  structureKeyNames: (keyName, multipleReasons) =>
    if !multipleReasons && keyName == "Reasons"
      keyName = "Reason"

    if keyName in ["Reasons", "Reason"]
      keyName = "Decision #{keyName}"
    return keyName

  handleEmptyState: (keyName, content) => 
    if keyName == "Comment" && content == "N/A"
      content = "<i>No comment recorded</i>"
    else if keyName == "LFA" && (!content || content == "Unassigned")
      content = "<i>Unassigned</i>"
    return content
