class SurveyV2.Respond.UI
  constructor:(
      @getSurveysV2, 
      @getSurvey, 
      @submitResponse,
      @getSurveyRespondent,
      @getSurveyResponseData,
      @survey_response = {}
  ) ->
    questions = []
    response = []
    @contentPerPage = 16
    @surveysCount = 0
    @pagination = new PaginationControl.UI()
    @helpers = new Helpers.UI()
    
    @totalSections = ''
    @survey_sections = ''
    @currentSection = 0
    @stacked = ''
    @sectionOptions = {}
    @requiredOptionalQuestion = []
    @surveyResponseState = []
    @optionalSectionModal = new Modal.App('#confirm-optional-section-response-modal', 500, 500, 467, 467)
    @loader = new Loader.UI()

  debounce = (func, wait, immediate) ->
    timeout = undefined
    ->
      context = this
      args = arguments
      later = ->
        timeout = null
        if !immediate
          func.apply context, args
        return
      callNow = immediate and !timeout
      clearTimeout timeout
      timeout = setTimeout(later, wait)
      if callNow
        func.apply context, args
      return
  
  initializeEditResponse: ->
    @onEditResponse()

  initializeRespond: ->
    @initializeResponseState()
    @onToggleSelectDate()
    @initializeSurveyCards()
    @onRespond()
    @onToggleScaleValue()
    
  initializeTooltip: () ->
    $(document).tooltip({
      tooltipClass: "uitooltip",
      position: { my: "left-40 top-55 center", at: "right center" },
    })

  onRespond: () ->
    self = @
    if JSON.stringify(pageUrl.slice(1,3)) == JSON.stringify(['surveys-v2', 'respond'])
      self.getSurvey(pageUrl[3]).then(
        (data) ->
          self.survey_sections = data.survey_sections
          self.populateQuestion(data)
      )

  onToggleSelectDate: ->
    $(document).on 'click', (e) ->
      if (not $(e.target).is('.select-date')) and (not $(e.target).is('.ui-datepicker-prev')) and (not $(e.target).is('.ui-datepicker-next'))
        $('.calendar-item').hide()

  onToggleScaleValue: ->
    $('.scale-questions ul li').on 'click', ->
      $(this).parent().find('li').removeClass('active')
      $(this).addClass('active')

  onToggleQuestionDescription: (survey_question) ->

    description = ''
    if survey_question.description
      if survey_question.description_type == "text"
        description += 
          "<span class='title-icon pull-right' id='#{survey_question.id}' title='#{survey_question.description}'>
            <i class='material-icons md-18 md-dark pull-left'>help_outline</i>
          </span>"
      else if survey_question.description_type == "image"
        description +=
          "<br /><img class='description-answer image-desc' src='#{survey_question.description}'/>"
      else if survey_question.description_type == "video"
        description += 
          "<br /><video class='description-answer video-desc' src='#{survey_question.description}' controls width='400'/>"
    return description

  getRequiredQuestions: (surveys, survey_responses) ->
    self = @
    responses = JSON.parse(survey_responses.get('survey_responses')) 
    for section in surveys.survey_sections
      continue if section.survey_section_rules.length > 0
      for question in section.survey_questions
        if question.is_required and not responses["question_#{question.id}"]
          self.flashErrorMessage("Please fill all the required questions")
          return false
      return true

  getMultipleChoiceResponse: () ->
    self = @
    $('.answer input[type="radio"]').off('click').on('click', ->
      question_id = $(this).parents().eq(3).attr('id')
      if $(this).attr('name') == "option-#{question_id}"
        option_id =  $(this).parent('.answer').find('span').attr('option-id')
        question_id = $(this).parents().eq(3).attr('id')
        self.appendOptionalSection(this, option_id)
        $('select').selectmenu()
        question_type = $(this).parents().eq(3).attr('question_type')
        question_number = $(this).parents().eq(2).siblings().find('span').text()
        if ($(this).is(":checked") == true)
          multiple_choice_response = {
            option_id: option_id,
            question_id: question_id,
            question_type: question_type
            question_number: question_number
          }
        self.survey_response["question_#{question_id}"] = multiple_choice_response
    )
  getCheckboxResponse: ->
    self = @
    $('.answer input[type="checkbox"]').each(->
      question_id = $(this).parents().eq(3).attr('id')
      question_type = $(this).parents().eq(3).attr('question_type')
      question_number = $(this).parents().eq(2).siblings().find('span').text()
      $(this).on 'click', ->
        response = self.survey_response["question_#{question_id}"]
        if not response
          response = {
            checkbox_ids: [],
            question_id: question_id,
            question_type: question_type,
            question_number: question_number
          }
        checkbox_id =  $(this).parent('.answer').find('span').attr('option-id')
        if ($('input[type="checkbox"]').is(":checked"))
          if($.inArray(checkbox_id, response.checkbox_ids) != -1)
            response.checkbox_ids.splice($.inArray(checkbox_id, response.checkbox_ids), 1);
          else
            response.checkbox_ids.push(checkbox_id)
        else
          response.checkbox_ids.pop(checkbox_id);
        self.survey_response["question_#{question_id}"] = response
    )
    
  getDropdownResponse: ->
    self = @
    previous = ''
    $('select.survey-dropdown').on 'selectmenufocus', () ->
      previous = this.value
    $('select.survey-dropdown').on 'selectmenuchange', ->
      dropdown_id = $(this).find('option:selected').attr('option-id')
      self.appendOptionalSection(this, dropdown_id, previous)
      question_id = $(this).parents().eq(1).attr('id')
      question_type = $(this).parents().eq(1).attr('question_type')
      question_number = $(this).parents().eq(0).siblings().find('span').text()
      dropdown_response = {
        dropdown_id: dropdown_id,
        question_id: question_id,
        question_type: question_type,
        question_number: question_number
      }
      self.survey_response["question_#{question_id}"] = dropdown_response
          
  getPictureOptionResponse: ->
    self = @
    $('.option-image-list-item input[type="radio"]').off('click').on('click', ->
      picture_id =  $(this).parent('.option-image-list-item').find('img').attr('image-id');
      self.appendOptionalSection(this, picture_id)
      $('select').selectmenu()
      question_id = $(this).parents().eq(3).attr('id')
      question_type = $(this).parents().eq(3).attr('question_type')
      question_number = $(this).parents().eq(2).siblings().find('span').text()
      picture_option_response = {
        picture_id: picture_id
        question_id: question_id
        question_type: question_type
        question_number: question_number
      }
      self.survey_response["question_#{question_id}"] = picture_option_response
    )

  getPictureCheckboxResponse: ->
    self = @
    $('.checkbox-image-list-item input[type="checkbox"]').each(->
      question_id = $(this).parents().eq(3).attr('id')
      question_type = $(this).parents().eq(3).attr('question_type')
      question_number = $(this).parents().eq(3).siblings().find('span').text()
      $(this).on 'click', ->
        picture_checkbox_response = self.survey_response["question_#{question_id}"]
        if not picture_checkbox_response
          picture_checkbox_response = {
            picture_checkbox_ids: []
            question_id: question_id
            question_type: question_type
            question_number: question_number
          }
        picture_checkbox_id =  $(this).parent('.checkbox-image-list-item').find('img').attr('image-id')
        if ($('input[type="checkbox"]').is(":checked"))  
          if($.inArray(picture_checkbox_id, picture_checkbox_response.picture_checkbox_ids) != -1) 
            picture_checkbox_response.picture_checkbox_ids.splice($.inArray(picture_checkbox_id, picture_checkbox_response.picture_checkbox_ids), 1);
          else
            picture_checkbox_response.picture_checkbox_ids.push(picture_checkbox_id)
        else
          picture_checkbox_response.picture_checkbox_ids.pop(picture_checkbox_id);
        self.survey_response["question_#{question_id}"] = picture_checkbox_response
    )

  getDateResponse: (questions) ->
    self = @
    dateInput = $('.calendar-wrapper').find('input')
    date_limits = ''
    question_id = ''
    dateInput.on 'click', ->
      calendar = $(this).siblings()
      question_number = $(this).parents().eq(4).siblings().find('span').text()
      calendar.show()
      question_id = parseInt($(this).parents().eq(5).attr('id'))
      [{date_limits}] = (question for question in questions when question.id is question_id)
      calendar.datepicker({
        minDate: date_limits.min && new Date(date_limits.min)
        maxDate: date_limits.max && new Date(date_limits.max) 
      })
      calendar.on('change', ->
        date_value = $(this).val();
        question_type = $(this).parents().eq(5).attr('question_type')
        $(this).siblings().val(date_value)
        date_response = {
          value: date_value,
          question_id: question_id,
          question_type: question_type,
          question_number: question_number
        }
        self.survey_response["question_#{question_id}"] = date_response
      )

    dateInput.change -> 
      if isNaN(Date.parse($(this).val()))
        self.survey_response["question_#{question_id}"] = null
        self.flashErrorMessage("Please enter a valid date")
        $(this).focus()
        return $(this).val('')
      return if !date_limits
      is_less_than_min = date_limits.min && new Date($(this).val()) < new Date(date_limits.min)
      is_greater_than_max = date_limits.max && new Date($(this).val()) > new Date(date_limits.max)
      if is_less_than_min || is_greater_than_max
        self.survey_response["question_#{question_id}"] = null
        self.flashErrorMessage("Please enter a date within the limits on the calendar")
        $(this).focus()
        $(this).val('')  

  getHourResponse: () ->
    self = @
    question_id = $('.time-wrapper').parents().eq(1).attr('id')
    hours = $('.main-display').find('input[placeholder="01:"]').attr('id', "#{question_id}")
    hours.keyup (event) ->
      key = if window.event then event.keyCode else event.which
      if event.keyCode == 8 or event.keyCode == 46
        return true
      else if key < 48 || key > 57 || $(this).val() > 12
        self.flashErrorMessage("Please enter a valid time")
        $(this).val("")
      else
        self.getTimeResponse()
    
  getMinuteResponse: () ->
    self = @
    minutes = $('.main-display').find('input[placeholder="01"]')
    minutes.keyup (event) ->
      key = if window.event then event.keyCode else event.which
      if event.keyCode == 8 or event.keyCode == 46
        return true
      else if key < 48 || key > 57 || $(this).val() > 60
        self.flashErrorMessage("Please enter a valid time")
        $(this).val("")
      else
        self.getTimeResponse()

  getTimePeriodResponse: ->
    self = @
    am_pm = $('.am-pm').find('select')
    time_value = am_pm.val()
    am_pm.on('change', ->
      question_id = $(this).parents().eq(6).attr('id')
      hour_value = $('input[placeholder="01:"]').attr('id', "#{question_id}").val()
      minute_value = $('input[placeholder="01"]').attr('id', "#{question_id}").val()
      if minute_value and hour_value
        self.getTimeResponse()
      else
        self.flashErrorMessage("Please enter a valid time")
    )
      

  getTimeResponse: () ->
    self = @
    $('.main-display').each(->
      question_id = $(this).parents().eq(4).attr('id')
      question_type = $(this).parents().eq(4).attr('question_type')
      question_number = $(this).parents().eq(3).siblings().find('span').text()
      response = self.survey_response["question_#{question_id}"]
      hour_value = $(this).find('input[placeholder="01:"]').attr('id', "#{question_id}").val()
      minute_value = $(this).find('input[placeholder="01"]').attr('id', "#{question_id}").val()
      time = "#{hour_value} : #{minute_value}
            #{$(this).find('.am-pm').find('select').val()}"     
      time_response = {
        value: time,
        question_id: question_id,
        question_type: question_type 
        question_number: question_number
      }
      self.survey_response["question_#{question_id}"] = time_response
    )
    
  getParagraphResponse: () ->
    self = @
    paragraph = $('.paragraph-wrapper')
    paragraph.each(->
      $(document).ready(->
        paragraph.keyup debounce((->
          paragraph_value = $(this).find('textarea').val()
          question_id = $(this).parents().eq(1).attr('id')
          question_type = $(this).parents().eq(1).attr('question_type')
          question_number = $(this).parents().eq(0).siblings().find('span').text()
          paragraph_response = {
            value: paragraph_value
            question_id: question_id
            question_type: question_type
            question_number: question_number
          }
          self.survey_response["question_#{question_id}"] = paragraph_response
        ), 1000)
      )
    )
     
  getScaleResponse: ->
    self = @
    $('.no-padding-left li').on 'click', ->
      scale_value = $(this).html()
      question_id = $(this).parents().eq(3).attr('id')
      question_type = $(this).parents().eq(3).attr('question_type')
      question_number = $(this).parents().eq(2).siblings().find('span').text()
      scale_response = {
        value: scale_value,
        question_id: question_id,
        question_type: question_type,
        question_number: question_number
      }
      self.survey_response["question_#{question_id}"] = scale_response

  getMultiChoiceGridResponse: ->
    self = @
    choice_response = []
    $('.radio-container input[type="radio"]').each(->
      $(this).on 'click', ->
        row_id = $(this).attr('data-row-id')
        col_id = $(this).attr('data-col-id')
        i = 0
        while i < choice_response.length
          if choice_response[i][0] == row_id
            choice_response.splice i, 1
          i++
        choice_response.push([row_id, col_id])

        question_id = $(this).parents().eq(7).attr('id');
        question_type = $(this).parents().eq(7).attr('question_type');
        question_number = $(this).parents().eq(6).siblings().find('span').text()
        multi_choice_grid_response = {
          choice_response: choice_response,
          question_id: question_id,
          question_type: question_type
          question_number: question_number
        }
        self.survey_response["question_#{question_id}"] = multi_choice_grid_response
    )

  getCheckboxGridResponse: ->
    self = @
    checkbox_response = []
    $('.checkmark-container input[type="checkbox"]').each(->
      $(this).on 'click', ->
        if ($(this).is(":checked") == true)
          row_id = $(this).attr('data-row-id')
          col_id = $(this).attr('data-col-id')
          checkbox_response.push([row_id, col_id])
        else
          row_id = $(this).attr('data-row-id')
          col_id = $(this).attr('data-col-id')
          i = 0
          while i < checkbox_response.length
            if checkbox_response[i][0] == [row_id, col_id][0] && checkbox_response[i][1] == [row_id, col_id][1]
              checkbox_response.splice i, 1
            i++
        question_id = $(this).parents().eq(7).attr('id');
        question_type = $(this).parents().eq(7).attr('question_type');
        question_number = $(this).parents().eq(6).siblings().find('span').text()
        checkbox_grid_response = {
          checkbox_response: checkbox_response,
          question_id: question_id,
          question_type: question_type
          question_number: question_number
        }
        self.survey_response["question_#{question_id}"] = checkbox_grid_response
    )
  
  getResponses: (questions)->
    @getDropdownResponse()
    @getPictureOptionResponse()
    @getPictureCheckboxResponse()
    @getScaleResponse()
    @getMultiChoiceGridResponse()
    @getCheckboxGridResponse()
    @getDateResponse(questions)
    @getTimePeriodResponse()
    @getMultipleChoiceResponse()
    @getParagraphResponse()
    @getCheckboxResponse()
    @getHourResponse()
    @getMinuteResponse()

  getSurveyResponses: (surveys) ->
    self = @
    survey_response = self.survey_response
    return self.flashErrorMessage "Please fill in at least one option" if Object.keys(survey_response).length == 0
    form = new FormData()
    form.append('survey_id', surveys.id)
    form.append('survey_responses', JSON.stringify(survey_response))
    for key, value of survey_response
      form.append(key, value)
    return form

  populateQuestionRequired: (survey_question) ->
    required = "<small id='toggle'><span>*</span> Required</small>"
    if survey_question.is_required == true then required else ''

  populateSections: (survey, question_number, section_count) ->
    section =
      "<div id='survey_section_#{section_count}' class='ui-helper-hidden'>
         <div class='section-preview-title'>
            <span>SECTION #{section_count}</span>
         </div>"
    for survey_question in survey.survey_questions
        question =
          "<div class='mdl-grid mdl-grid--no-spacing question' id=#{survey_question.id} question_type=#{survey_question.type}>
            <div class='mdl-cell mdl-cell--1-col mdl-cell--1-col-phone mdl-cell--1-col-tablet'>
              <div class='respond-modal--question-number is-circular is-primary flex'>
                <span class='list-no'>#{question_number}</span>
              </div>
            </div>
            <div class='mdl-cell mdl-cell--11-col mdl-cell--11-col-phone mdl-cell--11-col-tablet question_content'>
              <div class='question-content'>
                <p>#{survey_question.question}</p>
                #{@onToggleQuestionDescription(survey_question)}
              </div> 
              #{@populateQuestionTypes(survey_question, surveys.survey_sections)}
              #{@populateQuestionRequired(survey_question)}
            </div>
           </div>"
        section += question
        question_number = question_number + 1
    $('.question-wrapper').append(section + "</div>")
    $('.survey-dropdown').selectmenu()
    @onToggleSelectDate()
    @onToggleScaleValue()
    @getResponses(survey.survey_questions)
    @initializeTooltip()

  populateQuestion: (surveys) ->
    question_number = 1
    sectionCount = 0
    @currentSection = 1
    for survey in surveys.survey_sections
      continue if survey.survey_section_rules.length > 0
      sectionCount += 1
      @populateSections(survey, question_number, sectionCount)
    @totalSections = sectionCount
    $("#prev-preview,#next-preview").removeClass('ui-helper-hidden')
    if @totalSections == 1
      $('#next-preview').hide()
      $('.respond-submit-btn').removeClass('ui-helper-hidden')
    $('#prev-preview').hide()
    @renderSurveySection()
    @handlePreviewClick()
    @onSubmitResponse(surveys)
    @reorderNumbering()

  handlePreviewClick: ->
    $('#prev-preview').off('click').on('click', =>
       --@currentSection
       $("#next-preview").show()
       $(".respond-submit-btn").addClass('ui-helper-hidden')
       if @currentSection == 1
         $('#prev-preview').hide()
       $("#survey_section_#{@currentSection+1}").addClass('ui-helper-hidden')
       @renderSurveySection(@currentSection)
    )

    $('#next-preview').off('click').on('click', =>
      ++@currentSection
      $('#prev-preview').show()
      if @currentSection == @totalSections
        $("#next-preview").hide()
        $(".respond-submit-btn").removeClass('ui-helper-hidden')
      $("#survey_section_#{@currentSection - 1}").addClass('ui-helper-hidden')
      @renderSurveySection(@currentSection)
    )

  renderSurveySection: ->
    $("#survey_section_#{@currentSection}").removeClass('ui-helper-hidden')

  getOptionalSection: (survey_sections, option_id) ->
    for survey_section in survey_sections
      if survey_section.survey_section_rules[0] && survey_section.survey_section_rules[0].survey_option_id == Number(option_id)
        return survey_section

  optionalSectionBuild: (survey_section, target_id) ->
    question = ""
    for survey_question in survey_section.survey_questions
        question +=
          "<div class='mdl-grid mdl-grid--no-spacing question optional-#{target_id}' id=#{survey_question.id} question_type=#{survey_question.type}>
            <div class='mdl-cell mdl-cell--1-col mdl-cell--1-col-phone mdl-cell--1-col-tablet'>
              <div class='respond-modal--question-number is-circular is-primary flex'>
                <span class='list-no'>2</span>
              </div>
            </div>
            <div class='mdl-cell mdl-cell--11-col mdl-cell--11-col-phone mdl-cell--11-col-tablet question_content'>
              <div class='question-content'>
                <p>#{survey_question.question}</p>
                #{@onToggleQuestionDescription(survey_question)}
              </div> 
              #{@populateQuestionTypes(survey_question, survey_section)}
              #{@populateQuestionRequired(survey_question)}
            </div>
          </div>"
    question
  
  findOptionalSectionId: (target) ->
    target_id = ""
    for node_target in $(target).parentsUntil($(".mdl-grid.mdl-grid--no-spacing.question")).parents()
      if node_target.id
        target_id = node_target.id
        break
    target_id

  appendOptionalSection: (target, option_id, previous='') ->
    optionalSection = @getOptionalSection(@survey_sections, option_id)
    target_id = @findOptionalSectionId(target)
    if optionalSection
      if @stacked != target_id
        @stackSection(target, target_id, optionalSection)
      else
        newOptionId = $(@sectionOptions[target_id]).parents('.answer').find('span').attr('option-id')
        return unless option_id != newOptionId
        @optionalSectionModal.open()
        @handleMultipleLinkedOption(target, target_id, previous, optionalSection)
    else
      if @stacked == target_id || @sectionOptions[target_id]
        @optionalSectionModal.open()
        @stacked = ''
        @handleOptionalSectionModal(target, target_id, previous)
    @reorderNumbering()

  handleMultipleLinkedOption: (target, target_id, previous, optionalSection) ->
    $(".close_section_modal,.close-option-change").off('click').on('click', =>
      @handleOptionClick(target, target_id, previous)
      @optionalSectionModal.close()
    )
    $("#confirm-option-change").off('click').on('click', =>
      @updateSurveyResponses(target_id)
      $(".optional-#{target_id}").remove()
      @stackSection(target, target_id, optionalSection)
      @reorderNumbering()
      @optionalSectionModal.close()
    )
  handleOptionClick: (target, target_id, previous) ->
    if previous == ''
      $(@sectionOptions[target_id]).prop("checked", true).trigger('click')
    else
      $(target).val(previous).trigger('selectmenuchange')
      $(target).selectmenu('refresh')

  stackSection: (target, target_id, optionalSection) ->
    @sectionOptions[target_id] = target
    @stacked = target_id
    section = @optionalSectionBuild(optionalSection, target_id)
    $("##{target_id}").after(section)
    @getRequiredOptionalQuestion(optionalSection)
    $('select').selectmenu()
    @onToggleSelectDate()
    @initializeSurveyCards()
    @onToggleScaleValue()
    @getResponses()

  getRequiredOptionalQuestion: (optionalSection) ->
    for question in optionalSection.survey_questions
      continue if question.id in @requiredOptionalQuestion
      if question.is_required
        @requiredOptionalQuestion.push(question.id)

  isRequiredOptionalQuestion: (survey_responses) ->
    responses = JSON.parse(survey_responses.get('survey_responses')) 
    for question in @requiredOptionalQuestion
      if not responses["question_#{question}"]
        @flashErrorMessage("Please fill all the required questions")
        return false
    return true

  updateSurveyResponses: (target_id) ->
    questionId = []
    for target in $(".optional-#{target_id}")
      questionId.push(target.id)
    @removeResponsesFromSurvey(questionId)

  removeResponsesFromSurvey: (questionId) ->
    questionId.forEach (question) =>
      delete @survey_response["question_#{question}"]
      index = @requiredOptionalQuestion.indexOf(question)
      @requiredOptionalQuestion.splice(index, 1)

  handleOptionalSectionModal: (target, target_id, previous) ->
    $(".close_section_modal,.close-option-change").off('click').on('click', =>
      @handleRetainingOptions(target, target_id, previous)
      @optionalSectionModal.close()
    )
    $("#confirm-option-change").off('click').on('click', =>
      @updateSurveyResponses(target_id)
      $(".optional-#{target_id}").remove()
      delete @sectionOptions[target_id]
      @reorderNumbering()
      @optionalSectionModal.close()
    )
    
  removeDuplicate: (target_id) ->
    allNode = $('.question-wrapper').find(".optional-#{target_id}")
    firstNodeId = allNode[0].id
    for node, index in allNode
      if node.id == firstNodeId && index != 0
        break
      node.remove()
    @reorderNumbering()


  handleRetainingOptions: (target, target_id, previous) ->
    @handleOptionClick(target, target_id, previous)
    @removeDuplicate(target_id)
    
  reorderNumbering: () ->
    num = 1
    for target, index in $(".mdl-grid.mdl-grid--no-spacing.question").siblings()
      continue unless target.className != 'section-preview-title'
      $(target).find(".list-no").replaceWith("<span class='list-no'>#{num}</span>")
      num += 1

  populateQuestionTypes: (survey_question, survey_sections) ->
    self = @
    choices = ''
    questionable_type = survey_question.type
    switch questionable_type
      when "SurveySelectQuestion"
        choices = self.populateSelectQuestions(survey_question, survey_sections)
      when "SurveyMultipleChoiceQuestion"
        choices = self.populateMultipleChoiceQuestions(survey_question, survey_sections)
      when "SurveyCheckboxQuestion"
        choices = self.populateCheckboxQuestions(survey_question)
      when "SurveyMultigridOptionQuestion"
        choices = self.populateMultigirdChoiceOptionQuestions(survey_question)
      when "SurveyMultigridCheckboxQuestion"
        choices = self.populateMultigridCheckboxQuestions(survey_question)
      when "SurveyScaleQuestion"
        choices = self.populateScaleQuestions(survey_question)
      when "SurveyDateQuestion"
        choices = self.populateDateQuestions(survey_question)
      when "SurveyTimeQuestion"
        choices = self.populateTimeQuestions(survey_question)
      when "SurveyParagraphQuestion"
        choices = self.populateParagraphQuestions(survey_question)
      when "SurveyPictureOptionQuestion"
        choices = self.populatePictureMultipleChoiceQuestions(survey_question, survey_sections)
      when "SurveyPictureCheckboxQuestion"
        choices = self.populatePictureCheckboxQuestions(survey_question)
    return choices

  populateSelectQuestions: (survey_question, survey_sections) ->
    question_options = survey_question.survey_options
    choices = "<select class='survey-dropdown'>
          <option>Select</option>"
    question_options.map (option) ->
        choices +=  "
            <option option-id=#{option.id} class='data-select-#{option.id}' value='#{option.id}' question-id=#{survey_question.id}>#{option.option}</option>
        "
    choices += "</select>"

  populateMultipleChoiceQuestions: (survey_question, survey_sections) ->
    question_options = survey_question.survey_options
    choices = "<div>"
    for option in question_options
      choices += 
        "<div class='answer'>
          <input type='radio' class='data-#{option.id}' name='option-#{survey_question.id}'>
          <span class='item-option' option-id=#{option.id}>#{option.option}</span>
          <div class='custom-radio'></div>
        </div>"
    choices += "</div>"

  populateCheckboxQuestions: (survey_question) ->
    @question_options = survey_question.survey_options
    choices = "<div>"
    @question_options.map (option) ->
      choices += 
        "<div class='answer'>
          <input type='checkbox' class='data-#{option.id}' name='option-#{survey_question.id}'>
          <span class='item-option' option-id=#{option.id}>#{option.option}</span>
          <div class='custom-checkbox'></div>
        </div>"
    choices += "</div>"

  populateMultigirdChoiceOptionQuestions: (survey_question) ->
    @question_options = survey_question.survey_options
    cols = @question_options.columns
    rows = @question_options.rows
    row_options = ''
    option_labels = ''
    columns = ''

    cols.forEach (column) ->
      columns += "<th>#{column.option}</th>"

    table = ""
    rows.forEach (row) => 
      table += "<tr class='tr_row'><td>#{row.option}</td>"
      cols.forEach (col) => 
        table += 
          "<td>
            <label class='radio-container'>
              <input type='radio' class='data-#{row.id}-#{col.id}' data-row-id=#{row.id} data-col-id=#{col.id} name='name-#{survey_question.id}-#{row.id}'>
              <span class='radio-mark'></span>
            </label>
          </td>"
      table += "</tr>"

    choices =
      "<div class='table-responsive'>
        <table class='table'>
          <thead>
            <tr>
              <th></th>
              #{columns}
            </tr>
          </thead>
          <tbody>
            #{table}
          </tbody>
        </table>
      </div>"

  populateMultigridCheckboxQuestions: (survey_question) ->
    @question_options = survey_question.survey_options
    cols = @question_options.columns
    rows = @question_options.rows
    row_options = ''
    option_labels = ''
    columns = ''

    cols.forEach (column) ->
      columns += "<th>#{column.option}</th>"


    table = ""
    rows.forEach (row) =>
      table += "<tr class='tr_row'><td>#{row.option}</td>"
      cols.forEach (col) =>
        table += "<td>
            <label class='checkmark-container'>
              <input type='checkbox' class='data-#{row.id}-#{col.id}' data-row-id=#{row.id} data-col-id=#{col.id} name='name-0'>
              <span class='checkmark'></span>
            </label>
          </td>"
      table += "</tr>"

    choices =
      "<div class='table-responsive'>
        <table class='table'>
          <thead>
            <tr>
              <th></th>
              #{columns}
            </tr>
          </thead>
          <tbody>
            #{table}
          </tbody>
        </table>
      </div>"

  populateScaleQuestions: (survey_question) ->
    min_value = survey_question.scale.min
    max_value = survey_question.scale.max
    value = ''
    i = min_value

    while i <= max_value
      value += "<li class='data-scale-#{survey_question.id}-#{i}'>#{i}</li>"
      i++

    choices =  "<div class='scale-questions'>
        <ul class='no-padding-left'>
          #{value}
        </ul>
      </div>"

  populateDateQuestions: (survey_question) ->
    choices = 
      "<div class='calendar-wrapper calendar-#{survey_question.id}'>
        <div class='mdl-grid mdl-grid--no-spacing date'>
          <div class='mdl-cell mdl-cell--1-col mdl-cell--1-col-phone mdl-cell--1-col-tablet'>
          </div>
          <div class='mdl-cell mdl-cell--11-col mdl-cell--11-col-phone mdl-cell--11-col-tablet'>
            <div class='survey-item-container'>
              <input class='select-date cal data-date-#{survey_question.id}' data-question_type='#{survey_question.type}' data-question_id='#{survey_question.id}' id='question-0-select-date' type='text' placeholder='Select Date'>
              <div id='question-#{survey_question.id}-calendar' class='calendar-item calendar-#{survey_question.id}'></div>
            </div>
          </div>
        </div>
      </div>"

  populateTimeQuestions: (survey_question) ->
    choices = 
      "<div class='time-wrapper'>
        <div class='mdl-grid mdl-grid--no-spacing date'>
          <div class='mdl-cell mdl-cell--1-col mdl-cell--1-col-phone mdl-cell--1-col-tablet'>
          </div>
          <div class='mdl-cell mdl-cell--11-col mdl-cell--11-col-phone mdl-cell--11-col-tablet'>
            <div class='main-display'>
              <input class='display-time data-hour-#{survey_question.id}' type='number' placeholder='01:' size='2' maxlength='2' id='#{survey_question.id}'>
                <input class='display-time data-minutes-#{survey_question.id}' type='number'  placeholder='01' min='2' max='2' id='#{survey_question.id}'>
                  <div class='display-time am-pm'>
                    <select class='data-select-#{survey_question.id}'>
                      <option value='AM' class='data-AM-#{survey_question.id}' id='#{survey_question.id}'>AM</option>
                      <option value='PM' class='data-PM-#{survey_question.id}' id='#{survey_question.id}'>PM</option>
                    </select>
                  </div>
            </div>
          </div>
        </div>
      </div>"

  populateParagraphQuestions: (survey_question) ->
    choices = 
      "<div class='paragraph-wrapper' id='paragraph'>
        <div class='mdl-grid mdl-grid--no-spacing paragraph-txt'>
          <div class='mdl-cell mdl-cell--1-col mdl-cell--1-col-phone mdl-cell--1-col-tablet'>
          </div>
          <div class='mdl-cell mdl-cell--11-col mdl-cell--11-col-phone mdl-cell--11-col-tablet'>
            <textarea type='text' class='txt data-paragraph-#{survey_question.id}' rows='7' cols='39' id='textarea-#{survey_question.id}'></textarea>
          </div>
        </div>
      </div>"

  populatePictureMultipleChoiceQuestions: (survey_question, survey_sections) ->
    @question_options = survey_question.survey_options
    image_list = ''
    @question_options.map (option) ->
      image_list += 
        "<li class='option-image-list-item'>
          <input class='image-option data-#{option.id}' type='radio' name='selector-question-#{survey_question.id}'>
          <div class='custom-radio'></div>
          <img src='#{option.option}' alt='#{option.option_type}' image-id=#{option.id} class='image-description-placeholder checkbox-image' id='image-question-0-0' />
        </li>"
    choices = 
      "<ol>
        #{image_list}
      </ol>"

  populatePictureCheckboxQuestions: (survey_question) ->
    @question_options = survey_question.survey_options
    image_list = ''
    @question_options.map (option) ->
      image_list +=
        "<li class='checkbox-image-list-item'>
          <input class='image-checkbox data-#{option.id}' type='checkbox'>
          <div class='custom-checkbox'></div>
          <img class='image-description-placeholder checkbox-image' id='image-question-0-0' alt='#{option.option_type}' image-id=#{option.id} src='#{option.option}'>
        </li>"
    choices = 
      "<ol>#{image_list}</ol>"

  onSubmitResponse: (surveys) ->
    self = @
    $('.respond-submit-btn').on 'click', =>  
      survey_responses = self.getSurveyResponses(surveys)
      return unless self.getRequiredQuestions(surveys, survey_responses) &&
        self.isRequiredOptionalQuestion(survey_responses)
      self.submitResponse(survey_responses, surveys.id
        (response) -> (
          self.flashErrorMessage "An error occured")
        ).then((response) -> (
          self.flashSuccessMessage "Response Successfully Submitted"
          setTimeout (=>
              window.location.href = '/surveys-v2'
          ), 500
          ))

  initializeResponseState: ->
    self = @
    self.getSurveyRespondent()
    .then((response) -> (
      self.surveyResponseState = response
    ))

  initializeSurveyCards: ->
    self = @
    self.getSurveysV2(self.contentPerPage, self.pagination.page).then(
      (data) ->
        return unless data.admin == false
        surveyData = data.paginated_data
        self.surveysCount = data.surveys_count
        self.pagination.initialize(
          self.surveysCount, self.getSurveysV2,
          self.populateTable,  self.contentPerPage,
          {}, ".pagination-control.surveys-two-pagination"
        )
        self.populateTable(surveyData)
        )

  populateTable: (surveyData) =>
    self = @
    responseState = self.surveyResponseState.map((response) ->
      response.new_survey_id
    )

    if self.surveysCount == 0
      $(".dash-main").html("").append(
        "<div class='empty-survey'>
        <div class='empty-image'></div>
        <p>You have no pending surveys</p>
        </div>"
      )
      
    $("#learner-surveys").html("")

    # Filter all the surveys that are not yet overdue
    openSurveys = surveyData.filter (survey) -> new Date(survey.end_date) > new Date() and survey.status == "published"

    # Filter all surveys that are yet to be responded to
    pendingSubmissions = openSurveys.filter (survey) -> survey.survey_responses_count == 0

    # Display the surveys card
    openSurveys.forEach((survey) =>
      self.populateLearnerSurveys(survey, responseState)
    )

    # Display the number of surveys with response
    self.displaySurveyResponse(pendingSubmissions.length)


  displaySurveyResponse: (surveyResponseCount) ->
    response = 'submissions'
    if surveyResponseCount == 1
      response = 'submission'
    $("#surveys-count").html "You have #{surveyResponseCount} pending #{response}"

  populateLearnerSurveys: (survey, responseState) ->
    self = @
    if survey.id in responseState
      if survey.edit_response
        responseDetails = "<a href='/surveys-v2/respond/#{survey.id}' target='_blank' class='survey-text'>Edit Response</a>"
      else 
        self.surveysCount -= 1
        responseDetails = "<div class='survey-text'>Submitted</div>"
    else
      responseDetails = "<a href='/surveys-v2/respond/#{survey.id}' target='_blank' class='survey-text'>Take This Survey</a>"
    survey_cards = ""
    timer = self.timeLeft(survey.end_date)
    
    survey_cards +=
      "<div class='survey-card learners-survey-card' id='survey-#{survey.id}'>
        <div class='body response-card-body'>
          <div class='title response-title'>
            <span> VOF  </span>
            <br/>
            <p id='survey-title'>#{self.helpers.capitalizeSurvey(self.helpers.truncateTitle(survey.title))}</p>
              <span id='after'></span>
              <div id='title-tip'>
                #{survey.title}
              </div>
          </div>
          <div class='time'><div class='eye-icon'></div>
            <span id='rem-time'>#{ timer }</span>
          </div>
        </div>
        <div class='foot' id='take-survey'>
          <div class='resp' id='survey-footer'>
            #{responseDetails}
          </div>
        </div>
      </div>"

    $("#learner-surveys").append(survey_cards)

  onEditResponse: ->
    self = @
    self.getSurveyResponseData(pageUrl[3])
    .then((response) -> (
      if response
        self.loader.show()
        setTimeout (=>
          self.configureResponse(response)
          self.loader.hide()
        ), 1000
    ))

  configureResponse: (response) ->
    if response.survey_grid_option_responses.length
      response.survey_grid_option_responses.map((key) ->
        response_row_id = key.row_id
        response_col_id = key.col_id
        $(".data-#{key.row_id}-#{key.col_id}").click()
      )
    if response.survey_option_responses.length
      response.survey_option_responses.map((key) ->
        if key.question_type == "SurveySelectQuestion"
          $(".survey-dropdown").val(key.option_id).trigger('selectmenuchange')
          $(".survey-dropdown").selectmenu('refresh')
        if key.question_type == "SurveyMultipleChoiceQuestion" || "SurveyPictureOptionQuestion"
          $(".data-#{key.option_id}").attr("checked", true).click()
        $(".data-#{key.option_id}").click()
      )
    if response.survey_time_responses.length
      response.survey_time_responses.map((key) ->
        response_value = key.value.split('T')
        tmp = response_value[1].split(':')
        tempHour = tmp[0]
        minutes = tmp[1]
        hour = tempHour % 12
        meridiem = if tempHour > 11 then 'PM' else 'AM'
        $(".data-hour-#{key.question_id}").val(hour).keyup()
        $(".data-minutes-#{key.question_id}").val(minutes).keyup()
        $(".data-select-#{key.question_id}").val(meridiem).change()
      )
    if response.survey_date_responses.length
      response.survey_date_responses.map((key) ->
        response_value = key.value
        tmp = response_value.split('-')
        day = tmp[2]
        month = tmp[1]
        year = tmp[0]
        date = "#{month}/#{day}/#{year}"
        $(".calendar-#{key.question_id}").find('input').trigger('click')
        $(".calendar-#{key.question_id}").find('input').val(date).change()
        $(".question-content").trigger('click')
      )
    if response.survey_paragraph_responses.length
      response.survey_paragraph_responses.map((key) ->
        $(".data-paragraph-#{key.question_id}").text(key.value).keyup()
      )
    if response.survey_scale_responses.length
      response.survey_scale_responses.map((key) ->
        $(".data-scale-#{key.question_id}-#{key.value}").click()
      )

  timeLeft: (endDate) ->
    end = new Date(endDate)
    start = new Date()
    milliseconds = Math.floor((end.getTime() - start.getTime())+end.getTimezoneOffset()*60*1000)
    seconds = Math.floor milliseconds/1000
    minutes = Math.floor milliseconds/60000
    hours = Math.floor minutes/60
    days = Math.floor hours/24
    months = Math.floor days/30.417
    years = Math.floor days/365

    switch
      when years > 0 then "#{@pluralize(years, 'year')} left"
      when months > 0 then "#{@pluralize(months, 'month')} left"
      when days > 0 then "#{@pluralize(days, 'day')} left"
      when hours > 0 then "#{@pluralize(hours, 'hour')} left"
      when minutes > 0 then "#{@pluralize(minutes, 'minute')} left"
      when seconds > 0 then "#{@pluralize(seconds, 'second')} left"
      else "Overdue"

  pluralize: (count, val) ->
    type = if val.substring(0,1) == 'h' then 'an' else 'a'
    if count <= 0
      return "less than #{type} #{val}"
    if count == 1
      return "#{type} #{val}"
    return "#{count} #{val}s"

  flashErrorMessage: (message) =>
    @toastMessage(message, 'error')
    $('.respond-submit-btn').removeClass('disabled').addClass('is-success')

  flashSuccessMessage: (message) =>
    @toastMessage(message, 'success')
    $('.respond-submit-btn').removeClass('is-success').addClass('disabled')

  toastMessage: (message, status) =>
    $('.toast').messageToast.start(message, status)
