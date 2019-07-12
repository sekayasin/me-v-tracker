class Pitch.PitchLearnerSubmission.UI
  constructor: (@api) ->
    @ratingPreviewModal = new Modal.App('#rating-preview-modal', 600, 600, 800, 600)

  initialize: ->
    @backToAllLearners()
    @submitLearnersRating()

  backToAllLearners: ->
    $(".back_image").click ->
      window.location.href = "#{location.protocol}//#{location.host}/#{pageUrl[1]}/#{pageUrl[2]}"

  checkFormStatus: ->
    uiUx = $("input[name='name-0']:checked").val()
    apiFunctionality = $("input[name='name-1']:checked").val()
    errorHandling = $("input[name='name-2']:checked").val()
    projectUnderstanding = $("input[name='name-3']:checked").val()
    presentationalSkill = $("input[name='name-4']:checked").val()
    decision = $("input[name='option']:checked").val()
    comment = $.trim($("#comment").val())
    pitchId = pageUrl[2]
    learnerId = pageUrl[3]

    learnerRatings = { uiUx, apiFunctionality, errorHandling, projectUnderstanding,presentationalSkill, decision, comment, pitchId, learnerId }
    $.each(learnerRatings, (key, value) ->
      if !value
        return learnerRatings = false
      )
    return learnerRatings

  submitLearnersRating: () ->
    self = @
    $("#learner_rating-container--submit-btn").off 'click'
    $("#learner_rating-container--submit-btn").on 'click', (e) ->
      e.preventDefault();
      learnerRatings = self.checkFormStatus()
      if !learnerRatings
        return self.flashErrorMessage("Kindly fill in the missing fields")

      self.openRatingPreviewModal(learnerRatings)

  openRatingPreviewModal: (learnerRatings) ->
    self = @

    $('#preview').html("<div class='rating_preview'>
      <table align='center' cellpadding='4rem'>
        <tr><td align='left'>UI/UX Design:</td> <td align='right' class='rating-value'> #{learnerRatings.uiUx}</td></tr>
        <tr><td align='left'>Api Functionality: </td> <td align='right' class='rating-value'> #{learnerRatings.apiFunctionality}</td></tr>
        <tr><td align='left'>Error Handling: </td> <td align='right' class='rating-value'> #{learnerRatings.errorHandling}</td></tr>
        <tr><td align='left'>Project Understanding: </td> <td align='right' class='rating-value'> #{learnerRatings.projectUnderstanding}</td></tr>
        <tr><td align='left'>Presentational Skill: </td> <td align='right' class='rating-value'> #{learnerRatings.presentationalSkill}</td></tr>
        <tr><td align='left'>Decision: </td> <td align='right' class='rating-value'> #{learnerRatings.decision}</td></tr>
      </table>
      <br>
      <div class='comment-rating'>Comment: <div class='comment-value'>#{learnerRatings.comment}</div></div>

      </div>")

    self.ratingPreviewModal.open()

    $('#continue-rating-btn').off('click').click ->
      self.api.submitLearnersRating(learnerRatings, self.flashErrorMessage)
        .then((data) -> (
          if data.message == "An error occurred"
            self.flashErrorMessage(data.message)
          else
            self.flashSuccessMessage(data.message)
            window.location.href = "#{location.protocol}//#{location.host}/#{pageUrl[1]}/#{data.id}"
        ))
      self.ratingPreviewModal.close()

    $('#close_preview_modal').on 'click', ->
      self.ratingPreviewModal.close()

  toastMessage: (message, status) =>
    $('.toast').messageToast.start(message, status)

  flashErrorMessage: (message) =>
    @toastMessage(message, 'error')

  flashSuccessMessage: (message) =>
    @toastMessage(message, 'success')
