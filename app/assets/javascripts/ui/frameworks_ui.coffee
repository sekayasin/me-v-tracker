class Frameworks.UI
  constructor: ->
    @emptyState = new EmptyState.UI()
    @modal = new Modal.App('.edit-framework-modal', 500, 500, "auto", "auto")
    @loaderUI = new Loader.UI()
    @allFrameworks = []
    @selectedFramework = ''
    @currentPosition = 0

  initializeFrameworksTab: (getFrameworks) =>
    if !@allFrameworks
      $(".frameworks-table-wrapper").hide()

    getFrameworks()

  populateFrameworksTable: (curriculumDetails) =>
    self = @
    $(".frameworks-table-wrapper").show()
    $("#frameworks-body").html("")

    if curriculumDetails.frameworks.length == 0
      $(".frameworks-header-table").hide()
      $("#frameworks-body").append(self.emptyState.getNoContentText())
    else
      $(".frameworks-header-table").show()
      @allFrameworks = curriculumDetails.frameworks

      for framework in curriculumDetails.frameworks
        frameworksRow =
        """<tr class='frameworks-row-wrapper'>
            <td class='framework-row-name'> <span>#{framework.name}</span></td>
            <td class='#{self.setDescriptionClass(curriculumDetails.is_admin)}'>
              <span>#{framework.description}</span>
            </td>
            #{self.setActionColumn(curriculumDetails.is_admin, framework.id)}
        </tr>"""

        $("#frameworks-body").append(frameworksRow)
      
      if curriculumDetails.is_admin is true
        self.editFrameworkListener()

  setDescriptionClass: (isAdmin) ->
    className = "frameworks-row-description"

    if isAdmin is true
      className += "-admin"

    return className

  setActionColumn: (isAdmin, frameworkId) ->
    if isAdmin is true
      return "<td class='action-data'>
        <span id='edit-framework-#{frameworkId}' class='edit-framework-icon'></span>
      </td>"
    else
      return ""

  editFrameworkListener: ->
    self = @
    $('.edit-framework-icon').click ->
      frameworkId = Number($(this).attr("id").split("-")[2])
      self.openFrameworkModal()
      self.populateModalDescription(frameworkId)

      $('.close-button, .ui-widget-overlay').click ->
        self.closeFrameworkModal()

  populateModalDescription: (frameworkId) ->
    self = @
    @selectedFramework = (framework for framework in self.allFrameworks when framework.id == frameworkId)[0]

    $("#framework-name-input").val(@selectedFramework.name)
    $("#framework-description-input").val(@selectedFramework.description)

  submitFrameworkForm: (updateFramework) ->
    self = @
    
    $('.edit-framework-save').click =>
      self.validateInput()

      if $('#edit-framework-form').valid() 
        description = $('.framework-description-input').val()
        self.loaderUI.show()
        updateFramework(@selectedFramework.id, { description })

  showToastNotification: (message, status) ->
    $('.toast').messageToast.start(message, status)

  openFrameworkModal: ->
    self = @
    @currentPosition = $(window).scrollTop()
    window.scrollTo(0, 0)
    self.modal.open()
    $('body').css('overflow', 'hidden')

  closeFrameworkModal: ->
    self = @
    $('body').css('overflow', 'auto')
    self.clearDescriptionError()
    self.modal.close()
    $(window).scrollTop(@currentPosition)

  validateInput: -> 
    $.validator.addMethod 'flag-whitespace', ( ->
      notEmpty = $('.framework-description-input').val().trim().length > 0
      
      if (notEmpty)
        return true

      return false

    ), $.validator.messages.required

    $('#edit-framework-form').validate
      focusInvalid: false
      ignore: []

      rules:
        framework_description_input: {
          required: true,
          'flag-whitespace': true
        }

      messages:
        framework_description_input: 'Framework description is required!'

      errorPlacement: (error, element) ->
        if element.attr('name') == 'framework_description_input'
          $('#framework-description-error').html error

  clearDescriptionError: =>
    $('.framework-description-error').html ''
