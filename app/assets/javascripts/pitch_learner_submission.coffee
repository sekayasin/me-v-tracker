$(document).ready =>
  if pageUrl[1] == "pitch"
    pitchLearnerSubmission = new Pitch.PitchLearnerSubmission.App()
    pitchLearnerSubmission.start()
