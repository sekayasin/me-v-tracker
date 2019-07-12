class Pitch.LearnerRatingModal.UI
  constructor: (@api)->
    @learnerRatingModal = new Modal.App('#learner-modal-dialog', 880, 900 , 690, 690)
    @panelistView = false
    @totalratings = []

  handleBodyClick: () =>
    self = @
    $('.ui-widget-overlay, #preview-close').on 'click',  ->
      self.learnerRatingModal.close()
      $('.lfa-modal-dialog').css({'display':'none'})
      $('.view-score-breakdown').text('View score breakdown')
      $('<span><i class="fa fa-angle-down"></i></span>').appendTo( $( ".view-score-breakdown" ) );

  initialiseModal: () =>
    self = @
    @handleBreakdownToggle()
    $('.learner-pitch-tab-card, .rated-learner-message').off('click').click (e) ->
      self.learners_pitch_id = $(this).children().closest(".persona-card-body, .panelist-card__content").attr('id')
      self.panelistView = $(this).parent()[0].className.indexOf('panelist-cards') > -1
      if self.panelistView
        $('.admin-learner-dropdown').css({'display': 'none'})
        $('.panelist-learner-dropdown').css({'display': 'flex'})
        $('.panelist-comment').css({'display': 'block'})
      else
        $('.panelist-learner-dropdown, .panelist-comment').css({'display': 'none'})
        $('.admin-learner-dropdown').css({'display': 'flex'})

      self.api.getLearnerRatings(self.learners_pitch_id, self.flashErrorMessage)
        .then((data)->
          ratingsData
          panelistEmail = data.rating_details.panelist_email
          self.isPanelist = !!panelistEmail
          if self.isPanelist
            ratingsData = data.rating_details.ratings
              .filter((i) -> i.panelist_email == panelistEmail)
          else
            ratingsData = data.rating_details.ratings
          learnersData = data.rating_details.learner
          
          if ratingsData.length == 0
            message = "Learner is yet to be graded."
            self.flashErrorMessage message
          else
            self.setModalTitle(learnersData)
            $(".lfa-modal-dialog-field").html("")
            self.populateRatingsModal(ratingsData)
            $('.learners-rating-modal-content ').css({'padding-bottom': '97px'})
            self.learnerRatingModal.open()
            self.handleBodyClick()
        )


  handleBreakdownToggle: () ->
    $('.learner-dropdown').off('click').click () ->
      $('.lfa-modal-dialog').toggle();
      if ($('.lfa-modal-dialog').css('display') == 'block')
        $('.view-score-breakdown').text('Hide score breakdown')
        $('<span><i class="fa fa-angle-up"></i></span>').appendTo( $( ".view-score-breakdown" ) );
        $('.learners-rating-modal-content ').css({'padding-bottom': '20px'})
      else
        $('.view-score-breakdown').text('View score breakdown')
        $('<span><i class="fa fa-angle-down"></i></span>').appendTo( $( ".view-score-breakdown" ) );
        $('.learners-rating-modal-content ').css({'padding-bottom': '97px'})

  toastMessage: (message, status) ->
    $('.toast').messageToast.start(message, status)

  flashErrorMessage: (message) ->
    @toastMessage(message, 'error')

  setModalTitle: (learnersData) ->
    learner_names = "#{learnersData.first_name} #{learnersData.last_name}"
    first_letter = learnersData.first_name.slice(0,1)
    second_letter = learnersData.last_name.slice(0,1)
    learner_image = """<img src="https://ui-avatars.com/api/?name=#{first_letter}+%20#{second_letter}
    &background=195BDC&color=fff&size=128" alt="panelist image">"""
    $(".learner-header-name, .learner-name").html(learner_names)
    $(".learner-email").html(learnersData.email)
    $(".learner-image").html("").append(learner_image)

  averageRating: (key, data) ->
    self = @
    averageValue
    sumValue = 0
    value = (eachRating) ->
      self.totalratings.push(eachRating[key])
      eachRating[key]
    sumValue += value(eachRating) for eachRating in data
    return averageValue = (sumValue / data.length).toFixed(1)

  cumulativeAverage: (data) ->
    sumValue = data.reduce((a, b) -> a + b)
    averageValue = (sumValue /data.length).toFixed(1)

  populateRatingsModal: (ratingsData) =>
    decisions = ratingsData.map (elements) -> elements.decision

    self = @
    $(".ui-ux-rating").html(self.averageRating('ui_ux', ratingsData))
    $(".api-functionality-rating").html(self.averageRating('api_functionality', ratingsData))
    $(".error-handling-rating").html(self.averageRating('error_handling', ratingsData))
    $(".project-understanding-rating").html(self.averageRating('project_understanding', ratingsData))
    $(".presentation-skills-rating").html(self.averageRating('presentational_skill', ratingsData))
    $(".learner-cumulative-decision").html(getCumulativeDecision(decisions))
    $(".average-skills-rating").html(self.cumulativeAverage(self.totalratings))

    if self.panelistView
      $('.panelist-comment').html(ratingsData[0].comment)
    else
      ratingsData.forEach((rating) =>
        if rating.learners_pitch_id == parseInt(self.learners_pitch_id)
          self.populateLfaModalDialog(rating)
      )

  populateLfaModalDialog: (rating) ->
    name = rating.panelist_email.split(".")
    first_letter = name[0].slice(0,1)
    second_letter = name[1].slice(0,1)
    ratingDetails = """
    <div class="group-3">
        <ul class="group-3-rating">
          <div class="oval">
            <span class="panellist-full-name">#{name[0]} #{(name[1].split("@"))[0]}</span>
            <li class="ui-ux">
              <img src="https://ui-avatars.com/api/?name=#{first_letter}+%20#{second_letter}
              &background=195BDC&color=fff&size=128" alt="panelist image">
            </li>
          </div>
        </ul>
        <div class='flex-table'>
          <div class='rating-flex'>
            <ul>
              <li data-label="UI/UX"></li>
              <li class="lfa-rating-1">#{rating.ui_ux}</li>
            </ul>
          </div>
          <div class='rating-flex'>
            <ul>
              <li data-label="API Functionality"></li>
              <li class="lfa-rating-2">#{rating.api_functionality}</li>
            </ul>
          </div>
          <div class='rating-flex'>
            <ul>
              <li data-label="Error Handling"></li>
              <li class="lfa-rating-3">#{rating.error_handling}</li>
            </ul>
          </div>
          <div class='rating-flex'>
            <ul>
              <li data-label="Project Understanding"></li>
              <li class="lfa-rating-4">#{rating.project_understanding}</li>
            </ul>
          </div>
          <div class='rating-flex'>
            <ul>
              <li data-label="Presentational Skills"></li>
              <li class="lfa-rating-5">#{rating.presentational_skill}</li>
            </ul>
          </div>
        </div>
      </div>
    """
    $(".lfa-modal-dialog-field").append(ratingDetails)

  getCumulativeDecision = (decisions) ->
    decisions.forEach (el, i) ->
      if decisions[i] == "Yes"
        decisions[i] = 1
      else if decisions[i] == "No"
        decisions[i] = -1
      else if decisions[i] == "Maybe"
        decisions[i] = 0

    decision_value = decisions.reduce((a, b) -> a + b)
    cumulative_decision = switch
      when decision_value >= 1 then "Yes"
      when decision_value == 0 then "Maybe"
      when decision_value <= -1 then "No"
    return cumulative_decision
