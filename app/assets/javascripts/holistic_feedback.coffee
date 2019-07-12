$(document).ready ->
  if (pageUrl[1] == 'learners' && pageUrl[4] == 'scores')
    holisticFeedback = new HolisticFeedback.App()
    holisticFeedback.start()
