# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  accordion = new Accordion.App()
  accordion.start()

  tab = new Tab.App()
  tab.start()

  feedbackText = new FeedbackText.App()
  feedbackText.start()


