class Criteria.App
  constructor: ->
    @criteriaUI = new Criteria.UI()
    @criteriaAPI = new Criteria.API()
    @curriculumUI = new Curriculum.UI()
    @curriculum = new Curriculum.App()

  start: ->
    @criteriaUI.editCriteriaListener()
    @curriculumUI.submitEditCriteriaForm(@updateCriteria)
    @curriculumUI.deleteCriteriaModal(@deleteCriterion)

  updateCriteria: (criteriaId, details) =>
    self = @
    self.criteriaAPI.updateCriteria(criteriaId, details).then (response) ->
      if response.message
        self.curriculumUI.showToastNotification(response.message, "success")
        self.curriculumUI.closeEditCriteriaModal()
        self.curriculum.initializeTable()
      else if response.error
        self.curriculumUI.showToastNotification(response.error, "error")

      self.curriculumUI.loaderUI.hide()
    
  deleteCriterion: (criterionId) =>
    self = @
    self.criteriaAPI.deleteCriterion(criterionId).then (response) ->
      if response.message
          deletedCriteria = $('#criteria-body').find("#criterion-row-#{response.id}")
          count = Number($('span#criteria').text()) - 1
          $('span#criteria').text("#{count}")
          deletedCriteria.remove()
          self.criterionId = null
          self.curriculumUI.deleteCriterionModal.close()
          self.curriculumUI.showToastNotification(response.message, "success")
        else if response.error
          self.curriculumUI.showToastNotification(response.error, "error")


