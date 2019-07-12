$(document).ready ->
  if pageUrl[1] is 'pitch'

    if ((pageUrl[2] && typeof Number(pageUrl[2]) == 'number' && pageUrl.length == 3) ||
    pageUrl[2] is 'setup' || !pageUrl[2] || pageUrl[3] is 'edit')
      pitchSetupApp = new Pitch.PitchSetup.App()
      pitchSetupApp.start()
      pitchSetupTour = new Pitch.PitchSetupTour.App()
      pitchSetupTour.start()

    if pageUrl[3] is 'edit'
      pitchSetupApp.update(pageUrl[2])

    if (pageUrl.length == 4 && typeof Number(pageUrl[2]) == 'number' && typeof Number(pageUrl[3]) == 'number' )
      pitchRateLearnerTour = new Pitch.PitchRateLearnerTour.App()
      pitchRateLearnerTour.start()

    if !isNaN(pageUrl[2]) and !pageUrl[3]
      pitchPageTour = new Pitch.PitchPageTour.App()
      pitchPageTour.start()
