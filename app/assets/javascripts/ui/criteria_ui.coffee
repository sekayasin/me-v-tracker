class Criteria.UI
  constructor: ->
    @modal = new Modal.App(".edit-criterion-modal", 500, 500, "auto", "auto")

  editCriteriaListener: =>
    self = @
    $("#criteria-body").on 'click', 'span.edit-icon', ->
      self.modal.open()
      self.modal.setHeaderTitle('.edit-criterion-header', 'Edit Criterion')
      $('body').css('overflow', 'hidden')

      $('.edit-criterion-cancel, .close-button').click ->
        self.modal.close()
        $('body').css('overflow', 'auto')
