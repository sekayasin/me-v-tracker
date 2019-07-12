$(document).ready =>
  if (pageUrl[1] == "pitch" && typeof Number(pageUrl[2]) == 'number' && pageUrl[3] == "ratings" && pageUrl[4])
    pitchRatingBreakdown = new Pitch.PitchRatingBreakdown.App()
    pitchRatingBreakdown.start()
