$(document).ready =>
  learning_ecosystem = new LearningEcosystem.App()
  learning_ecosystem.start()
  
  if pageUrl[1] == 'learner' && pageUrl[2] == 'ecosystem'
    learningEcosystemPageTour = new LearningEcosystemPageTour.App()
    learningEcosystemPageTour.start()


