class LearnersProfile.UI
  constructor: ->
    @editLearnerModal = new Modal.App('#edit-personal-details-modal', 740, 700, 640, 640)
    @loaderUI = new Loader.UI()
    @personalDetailsFromView = {}

  closePersonalDetailsModal: ->
    self = @
    self.editLearnerModal.close()
    self.setupPersonalDetailsModal()
    self.hideFieldsError()
    self.hideImageError()
    $('body').css('overflow', 'auto')

  openPersonalDetailsModal: ->
    self = @
    self.editLearnerModal.open()
    $("#country-dropdown").selectmenu("option", "disabled", true)
    $("#city-dropdown").selectmenu("option", "disabled", true)
    $("#gender-dropdown").selectmenu("option", "disabled", true)
    $('body').css('overflow', 'hidden')

  getSelectedImage: ->
    image = $('#imageUpload')[0].files[0]
    if image instanceof File then image else null

  showImageError: (type) ->
    text = null
    if type == 'extension'
      text = 'Image should be of type JPEG or PNG'
    
    $('#image_error').css('color', '#ff0000').html(text) if text

  hideImageError: ->
    $('#image_error')
      .css('color', '#838383')
      .html('Change/Upload Profile Picture')
  
  showFieldsError: (erroredFields) ->
    for field in erroredFields
      element = $("##{field}_error")
      element.css('visibility', 'visible') if element.length

  hideFieldsError: ->
    $('.edit-modal-field-error').css('visibility', 'hidden')
  
  showPersonalDetailsModalErrors: (errors) ->
    self = @
    return unless Array.isArray(errors)
    imageError = null
    if 'image-extension' in errors
      imageError = 'extension'
    else if 'image-size' in errors
      imageError = 'size'
    
    self.showImageError(imageError) if imageError
    self.showFieldsError(errors)

  updatePersonalDetailsOnView: ->
    self = @
    viewFieldsMap = {
      about: 'view-about',
      phone_number: 'view-phone-number',
      username: 'view-username',
      github: 'view-github',
      trello: 'view-trello',
      website: 'view-website',
      linkedin: 'view-linkedin',
    }

    for dataField, viewField of viewFieldsMap
      value = self.actualViewValue(
        self.personalDetailsFromView[dataField]
      )
      if dataField == "trello" && value != "-"
        value = "https://trello.com/#{value}"
      $("##{viewField}").text(value)
    avatar = self.actualValue(
      self.personalDetailsFromView['avatar']
    )

    if avatar
      queryString = self.avatarQueryStr(avatar)
      $('#profile-image img').attr(
        'src', "#{avatar.trim()}#{queryString}"
      )

  personalDetailsChanged: (formdata) ->
    self = @
    avatar = self.actualValue($('#imageUpload').val())
    return true if avatar != null

    for key, value of self.personalDetailsFromView
      continue if (key == 'avatar' || key == 'country' || key == 'city' || key == 'gender')
      formvalue = self.actualFormValue(formdata.get(key)).trim()
      value = self.actualFormValue(value).trim()
      if formvalue != value
        return true
    false

  getPersonalDetailsAsFormData: ->
    self = @
    formData = new FormData($('#editLearnerDetailsForm')[0])
    formData.append('image', self.getSelectedImage())
    formData
  
  actualValue: (value) ->
    if (
      typeof(value) == 'string' &&
      value.trim().length != 0 &&
      value.trim() != '-'
    )
      value.trim()
    else
      null

  actualFormValue: (value) ->
    self = @
    value = self.actualValue(value)
    return '' if value == null
    value

  actualViewValue: (value) ->
    self = @
    value = self.actualValue(value)
    return '-' if value == null
    value

  avatarQueryStr: (avatar) ->
    maximum = 999999
    minimum = 10000
    number = Math.floor(
      Math.random() * (maximum - minimum) + minimum
    )
    if typeof avatar == 'string' && avatar.indexOf('?') <= -1
      "?#{number}"
    else
      ""

  updateHeaderImage: ->
    self = @
    avatar = self.actualValue(
      self.personalDetailsFromView['avatar']
    )
    return unless avatar
    queryString = self.avatarQueryStr(avatar)
    $('#header-profile-image').attr('src', "#{avatar}#{queryString}")

  updatePersonalDetailsFromView: (personalDetails) ->
    self = @
    return if typeof(personalDetails) != 'object'
    for field of self.personalDetailsFromView
      continue if field in ['country', 'city', 'gender']
      value = self.actualFormValue(personalDetails[field])
      self.personalDetailsFromView[field] = value

  setupPersonalDetailsModal: ->
    self = @
    dropdowns = ['gender', 'country', 'city']
    for field of self.personalDetailsFromView
      continue if (
        field in dropdowns ||
        field == 'avatar' ||
        field == 'about'
      )
      $("input[name='#{field}']").val(
        self.personalDetailsFromView[field]
      )

    if $("input[name='middle_name']").val() == '-'
      $("input[name='middle_name']").val('')
    
    $("textarea[name='about']").val(
      self.personalDetailsFromView['about']
    )

    avatar = self.personalDetailsFromView['avatar']
    if typeof avatar == 'string' && avatar.trim().length > 0
      $('#imageUpload').val('')
      queryString = self.avatarQueryStr(avatar)
      $('#image-preview').attr(
        'src', "#{avatar.trim()}#{queryString}"
      )

    for field in dropdowns
      $("select[name='#{field}']").val(
        self.personalDetailsFromView[field]
      )
      $("select[name='#{field}']").selectmenu('refresh')

  disableEditPersonalDetails: ->
    $('#edit-personal-details-modal').remove()
    $('.edit-personal-details-modal').remove()

  setModalLocation: (country) ->
    self = @
    if typeof country != 'string'
      country = self.actualFormValue(
        self.personalDetailsFromView["country"]
      ).toLowerCase()

      city = self.actualFormValue(
        self.personalDetailsFromView["city"]
      ).toLowerCase()
    else
      country = country.toLowerCase()
      city = ''
      
    locations = {
      kenya: ['Nairobi'],
      uganda: ['Kampala'],
      nigeria: ['Lagos'],
      rwanda: ['Kigali']
    }

    $('#city-dropdown').html('<option value="">Select</option>')
    if country of locations
      centers = locations[country]
      for center in centers
        selected = if city == center.toLowerCase() then 'selected' else ''
        $('#city-dropdown').append(
          "<option #{selected} value='#{center}'>#{center}</option>"
        )
    $('#city-dropdown').selectmenu('refresh')

  # Set initial personal details on page load
  storeMiniDetailsFromView: (initialData) ->
    self = @
    fields = ['gender', 'avatar', 'phone_number', 'about', 'username']
    for field in fields
      value = self.actualFormValue(initialData[field])
      self.personalDetailsFromView[field] = value

  storeLocationFromView: (initialData) ->
    self = @
    if typeof(initialData['location']) == 'object'
      fields = ['country', 'city']
      for field in fields
        value = self.actualFormValue(initialData['location'][field])
        self.personalDetailsFromView[field] = value
  
  storeLinksFromView: (initialData) ->
    self = @
    if typeof(initialData['links']) == 'object'
      fields = ['github', 'trello', 'website', 'linkedin']
      for field in fields
        value = self.actualFormValue(initialData['links'][field])
        self.personalDetailsFromView[field] = value

  storePersonalDetailsFromView: ->
    self = @
    initialJsonData = $('#personal_info').val()
    unless initialJsonData
      self.disableEditPersonalDetails()
      return

    initialData = JSON.parse(initialJsonData)
    return if typeof(initialData) != 'object'
    self.storeMiniDetailsFromView(initialData)
    self.storeLocationFromView(initialData)
    self.storeLinksFromView(initialData)

  # End

  bindImageChangeToPreview: ->
    self = @
    $('#imageUpload').on 'change', ->
      image = self.getSelectedImage()
      if image
        reader = new FileReader()
        reader.readAsDataURL(image)
        reader.onload = (event) ->
          $('#image-preview').attr 'src', event.target.result

  bindPersonalDetailsModalToClose: ->
    self = @
    $('.close-modal, .cancel-button').on 'click', ->
      self.closePersonalDetailsModal()

  bindPersonalDetailsModalToOpen: ->
    self = @
    $('.edit-personal-details-modal').on 'click', ->
      self.openPersonalDetailsModal()

  handleSuccessResponse: (response) =>
    self = @
    self.loaderUI.hide()
    if response.status
      # Execution order is important here
      self.updatePersonalDetailsFromView(
        response.personal_details
      )
      self.updatePersonalDetailsOnView()
      self.updateHeaderImage()
      self.closePersonalDetailsModal()
      $('.toast').messageToast.start(
        'Personal details updated successfully',
        'success'
      )
    else
      self.showPersonalDetailsModalErrors(response.errors)

  handleErrorResponse: (error) =>
    self = @
    self.loaderUI.hide()
    self.closePersonalDetailsModal()
    $('.toast').messageToast.start(
      'Internal error occured', 'error'
    )

  bindUpdateBtnToClick: (updatePersonalDetails) ->
    self = @
    $('#update-personal-details').on 'click', ->
      self.hideFieldsError()
      self.hideImageError()
      personalDetails = self.getPersonalDetailsAsFormData()
      if self.personalDetailsChanged(personalDetails)
        self.loaderUI.show()
        updatePersonalDetails(personalDetails).then(
          self.handleSuccessResponse,
          self.handleErrorResponse
        )
      else
        $('.toast').messageToast.start(
          'No change has been made', 'success'
        )

  initializeEditPersonalDetails: ->
    self = @
    self.bindPersonalDetailsModalToClose()
    self.bindPersonalDetailsModalToOpen()
    self.storePersonalDetailsFromView()
    self.bindImageChangeToPreview()
    $(document).ready ->
      self.setupPersonalDetailsModal()
      self.updateHeaderImage()
      self.setModalLocation()
      $("#country-dropdown").on 'selectmenuchange', ->
        self.setModalLocation(@value)
