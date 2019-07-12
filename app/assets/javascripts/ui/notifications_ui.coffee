class Notifications.UI
  constructor: (apiClearNotification) ->
    @toggleNotificationPane()
    @clearBulkNotification(apiClearNotification)
    @clearSingleNotification(apiClearNotification, 'close-button')
    @clearSingleNotification(apiClearNotification, 'notification-link')
    @handleNewProgramNotificationClick()
    @toggleNotificationHeader()
    @setTotalNotification()
    @activateReflectionAssessmentModal()
    @activateFeedbackAssessmentModal()

  toggleNotificationPane: =>
    self = @
    $('.notifications-trigger').on 'click', () ->
      $('.notifications-pane').animate({ right: '0' })
      $('body').css({ 'overflow': 'hidden' })
      $('.notifications-pane-backdrop').show()

    $('.notifications-pane-backdrop').on 'click', () ->
      self.closeNotificationPane('.notifications-trigger')

    $('.pane-header .close-button').on 'click', () ->
      self.closeNotificationPane('.notifications-trigger')

  closeNotificationPane: =>
    $('.notifications-pane').animate({ right: '-263px' })
    $('body').css({ 'overflow': 'auto' })
    $('.notifications-pane-backdrop').hide()

  toggleNotificationHeader: ->
    $('.switch-notification-class').on 'click', () ->
      archivedNotificationHeaderContent = ['Archives', 'Go Back']
      currentNotificationHeaderContent = ['Notifications', 'View Archives']
      switchNotificationText = $('.switch-notification-class').text()
      if switchNotificationText == 'View Archives'
        headerContent = archivedNotificationHeaderContent
        panelClass = ['archived', 'current']
        $('.switch-notification-class').attr('id', 'go-back')
      else
        headerContent = currentNotificationHeaderContent
        panelClass = ['current', 'archived']
        $('.switch-notification-class').removeAttr('id')

      $('.notification-header-text').text(headerContent[0])
      $('.switch-notification-class').text(headerContent[1])
      $("##{panelClass[0]}-panel").show()
      $("##{panelClass[1]}-panel").hide()

  displayEmptyNotification: ->
    if ($('#current-notifications .notification').length == 0)
      $('#current-notifications .empty-notification-message').removeClass('hidden')

  clearBulkNotification: (apiClearNotification) =>
    self = @
    $(document).on 'click', '.clear-notification-btn', () ->
      notificationIds = []
      closestNotifications = $(@).closest('.notification-box').find('.notification')

      closestNotifications
        .each((element) => notificationIds.push($(closestNotifications[element]).attr('data-id')))

      apiClearNotification(notificationIds)
      $(@).closest('.notification-box').find('.notification').remove()
      $(@).closest('.notification-box').remove()
      self.displayEmptyNotification()
      self.updateBadges()
      self.displayArchives()
      self.setTotalNotification()

  clearSingleNotification: (apiClearNotification, elClassName) =>
    self = @
    $(document).on 'click', ".current-notification .#{elClassName}", () ->
      closestNotifications = $(@).closest('.notification')
      allNotifications = $(@).closest('.notification-box').find('.notification')
      notificationIds = $(closestNotifications[0]).attr('data-id')

      apiClearNotification([notificationIds.toString()])

      if (allNotifications.length == 1)
        $(@).closest('.notification-box').remove()
        self.displayEmptyNotification()
      else
        $(@).closest('.notification').remove()
      self.updateBadges()
      self.displayArchives()
      self.setTotalNotification()

  displayArchives: ->
    $("#archives-box").load(" #archived-panel", () ->
      if $('.switch-notification-class').text() == 'Go Back'
        $("#archived-panel").show()
        $("#current-panel").hide()
    )

  updateBadges: ->
# TODO: Update this logic when "read" notifications view is implemented
    if $('.current-notification').length == 0
      $('.notification-icon').removeClass('has-notifications')
    else
      $('.notification-icon').addClass('has-notifications')

    $('.mobile-notifications-badge').attr('data-badge', $('.current-notification').length)

# Called in notification.js when websockets receives a new notification
  onReceiveNotification: (notification) =>
    @setTotalNotification()
    @displayToastNotification(notification)
    if $('.current-notification').length == 0
      $('#current-panel .notification-boxes').prepend(notification.html)
      $('#current-notifications .empty-notification-message').addClass('hidden')
      @updateBadges()
      @activateAssessmentModal()
    else
      $("#current-panel").load(" #current-panel")

  setTotalNotification: ->
    return unless $('.notification.current-notification').length != 0
    totalNotification = $('.notification.current-notification').length
    $('.notification-total').html(totalNotification)

  displayToastNotification: (notification) =>
    $("#notification-toast-content").html(notification.html.split(
      '<div class="notification-content" tabindex="0">')[1].split('</div>')[0].trim())
    $('.notification-toast').addClass('show')
    $('.notification-toast--close').click( ->
      $('.notification-toast').removeClass('show')
    )
    setTimeout(->
      $('.notification-toast').removeClass('show')
    , 5000)
 
  handleNewProgramNotificationClick: =>
    self = @
    $(document).on 'click', '.draft-program', () ->
      self.closeNotificationPane()
      $('.all-programs-button').click()

  activateReflectionAssessmentModal: =>
    $('.submission-notification-link').on 'click', (event) =>
      program_id = event.target.getAttribute('learner-program-id')
      localStorage.setItem('reflection_modal_data', JSON.stringify({
        assessment_id: event.target.getAttribute('assessment-id'),
        phase_id: event.target.getAttribute('phase-id'),
        feedback_id: event.target.getAttribute('feedback-id'),
        learner_program_id: program_id,
        phase_name: event.target.getAttribute('phase-name'),
      }))
      window.location.href = "/submissions/#{program_id}"

  activateFeedbackAssessmentModal: =>
    $('.learnerFeedback-notification-link').on 'click', (event) =>
      localStorage.setItem('feedback_modal_data', JSON.stringify({
        assessment_id: event.target.getAttribute('assessment-id'),
        phase_id: event.target.getAttribute('phase-id'),
        feedback_id: event.target.getAttribute('feedback-id'),
        phase_name: event.target.getAttribute('phase-name'),
      }))
      window.location.href = '/learner/ecosystem'
