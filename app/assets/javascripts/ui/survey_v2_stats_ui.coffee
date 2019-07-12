class SurveyV2.Stats.UI
  constructor: (
    @getASurvey,
    @getSurveyResponses,
    @shareSurvey,
    @getAllAdmin,
    @recipients,
    @survey_recipients = []
  ) ->
    @chart = new ChartJs.UI()
    @surveyResponseModal = new Modal.App('#main-response-modal', 636, 636, 352, 352)
    @surveyDownloadResponseModal = new Modal.App('#download-response-modal', 550, 550, 600, 352)
    @previewSurveyResponseImageModal = new Modal.App('#preview-image-modal', 550, 550, 600, 352)
    @surveyTitle = ''
    @surveyQuestions = []
    @surveyQuestionOptions = []
    @surveyResponses = []
    @bootcampers = []
    @surveyResponseStatus = false
    @surveyStatus = false
    @stats = {}
    @currentQuestion = 1
    @currentCamper = ''

  setup: () ->
    @getLearnerResponses()
    @initializeSingleViewAnchors()

  initializeSingleViewAnchors: () ->
    self = @
    $(document).ready(->
      $('.next').on 'click', ->
        offset = $('.question-'+self.currentQuestion).offset().top - $(".question-field").offset().top
        unless self.currentQuestion < self.surveyQuestions.length
          return false
        self.clickQuestion(++self.currentQuestion)
        $(".question-field").animate({ scrollTop: offset * 0.75 }, 100)
      $('.previous').on 'click', ->
        offset = $('.question-'+self.currentQuestion).offset().top - $(".question-field").offset().top
        unless self.currentQuestion > 1
          return false
        self.clickQuestion(--self.currentQuestion)
        $(".question-field").animate({ scrollTop: offset * 0.75 }, 100)

      $('#survey-respondents-button').on 'click', =>
        $('.ui-menu-item').off('click').on 'click', ->
          camper_email = $(this).text()
          response = self.getCurrentCamperResponse camper_email
    )

  getCurrentCamperResponse: (email) ->
    @currentCamper = email
    camper = @bootcampers.find((bootcamper) -> bootcamper[0] == email)
    if camper.length
      camper_response = @surveyResponses.find((response) -> response.respondable_id == camper[3])
    if camper_response
      return @setSingleViewResponse(camper_response)
    return null

  setSingleViewResponse: (camper_response) ->
    question_number = @currentQuestion
    question = @surveyQuestions.find((question) -> +question.position == +question_number)
    response = camper_response[@responseMapper(question['type'])].filter((response) -> +response.question_id == +question['id'])
    @handleSingleView question, response

  handleSingleView: (question, response) ->
    switch question['type']
      when "SurveyMultipleChoiceQuestion","SurveySelectQuestion","SurveyCheckboxQuestion","SurveyPictureOptionQuestion","SurveyMultipleChoiceQuestion","SurveyPictureCheckboxQuestion"
        @showChoiceOptions(question, response)
      when "SurveyMultigridOptionQuestion", "SurveyMultigridCheckboxQuestion" then @showGridChoiceOptions(question, response)
      when "SurveyDateQuestion" then @showChoiceDate(question, response)
      when "SurveyTimeQuestion" then @showChoiceTime(question, response)
      when "SurveyScaleQuestion" then @showChoiceScale(question, response)
      when "SurveyParagraphQuestion" then @showRespondentText(question, response)

  showGridChoiceOptions: (question, responses) ->
    rows = question['survey_options']['rows']
    cols = question['survey_options']['columns']
    content = ''
    keys = responses.map((response) -> { col_id: response.col_id, row_id: response.row_id })
    rowChoice = ''
    rows.map((row) ->
      rowChoice = row.option
      colChoices = ''
      cols.map((col) ->
        isCamperChoice = keys.filter((key) -> +key.col_id == +col.id && +key.row_id == +row.id).length
        colChoices += """<span class='response'>#{col.option}</span>""" if isCamperChoice
      )
      content += """
        <div class="date-time-container">
          <div class="date-time-pull-left"><strong>#{row.option}</strong></div>
          <div class="divider"></div>
          <div class="date-time-pull-right">#{colChoices}</div>
        </div>
      """
    )
    $('#single-response-dump').html content


  showRespondentText: (question, responses) ->
    content = ''
    responses.map((response) ->
      content += """
        <div class="question choice-back">
          <span class="option-text">#{response.value}</span>
        </div>
      """
    )
    $('#single-response-dump').html content

  showChoiceScale: (question, responses) ->
    content = ''
    responses.map((response) ->
      content += """
        <div class="question choice-back">
          <span class="option-text">#{response.value}</span>
        </div>
      """
    )
    $('#single-response-dump').html content

  showChoiceTime: (question, responses) ->
    content = ''
    responses.map((response) ->
      tmp = new Date(response.value)
      minutes = tmp.getMinutes()
      hour = tmp.getHours()
      meridiem = if hour > 11 then 'PM' else 'AM'
      content += """
        <div class="question choice-back">
          <span class="option-text">#{hour % 12} : #{minutes} #{meridiem}</span>
        </div>
      """
    )
    $('#single-response-dump').html content

  showChoiceDate: (question, responses) ->
    self = @
    content = ''
    responses.map((response) ->
      content += """
        <div class="question choice-back">
          <span class="option-text">#{self.processDate(response.value)}</span>
        </div>
      """
    )
    $('#single-response-dump').html content

  processDate: (date) ->
    month = {
      '01': 'January',
      '02': 'February',
      '03': 'March',
      '04': 'April',
      '05': 'May',
      '06': 'June',
      '07': 'July',
      '08': 'August',
      '09': 'September',
      '10': 'October',
      '11': 'November',
      '12': 'December'
    }
    dateMap = date.split('-')
    newFormattedDate = month[dateMap[1]] + ' ' + dateMap[2] + ', ' + dateMap[0]

  showChoiceOptions: (question, responses) ->
    self = @
    content = ''
    keys = responses.map((response) -> +response.option_id)
    question['survey_options'].map((option) ->
      isSelected =
        if keys.includes(+option.id)
          'choice-back'
        else
          ''
      option =
        if option.option_type == 'image'
          self.processMediaLink(option.option).base_name
        else
          option.option
      content += """
        <div class="question #{isSelected}">
          <span class="option-text">#{option}</span>
        </div>
      """
    )
    $('#single-response-dump').html content

  initializeResponses: =>
    self = @
    if pageUrl[2] == 'responses'
      @toggleResponseButtons()
      @displayChartOptions()
      preventDefault = true
      document.addEventListener('keydown', (event) ->
        if preventDefault
          event.preventDefault()
        code = event.which
        offset = $('.question-'+self.currentQuestion).offset().top - $(".question-field").offset().top
        switch
          when code == 38
            unless self.currentQuestion > 1
              return false
            self.clickQuestion(--self.currentQuestion)
            $(".question-field").animate({ scrollTop: offset * 0.75 }, 100)
          when (code == 40)
            unless self.currentQuestion < self.surveyQuestions.length
              return false
            self.clickQuestion(++self.currentQuestion)
            $(".question-field").animate({ scrollTop: offset * 0.75 }, 100)
        preventDefault = false
      )

  getLearnerResponses: () ->
    self = @
    survey_id = pageUrl[3]
    self.getASurvey(survey_id, (error)-> console.error 'error', error.message).then(
      (data) ->
        $('.survey_title_text').text data.title
        data['survey_sections'].map((section) ->
          return self.surveyQuestions = [self.surveyQuestions..., section.survey_questions...]
        )
        self.surveyStatus = true
        self.setQuestions self.surveyQuestions
        return self.aggregateStatFields() if self.surveyResponseStatus
    )

    self.getSurveyResponses(survey_id, (error)-> console.error 'error', error.message).then(
      (data) ->
        self.surveyResponses = data['response']
        self.bootcampers = data['bootcampers']
        self.surveyResponseStatus = true
        self.setResponseCount()
        self.setRespondents()
        return self.aggregateStatFields() if self.surveyStatus
    )

  setRespondents: ->
    camper_dropdown_data = ''
    @bootcampers.map((bootcamper) ->
      camper_dropdown_data += "<option id='respondent-#{bootcamper[3]}' data='#{bootcamper[3]}' value='0'>#{bootcamper[0]}</option>"
    )
    $('.survey-dropdown').html camper_dropdown_data

  setQuestions: () ->
    self = @
    questions = ''
    @surveyQuestions.map((question) ->
      questions += """
        <div
          question-no='#{question['position']}'
          class="item-container chart-question #{self.chartMapper(question.type)} question-#{question['position']}">
          <div question-no='#{question['position']}' class="question">
            <span question-no='#{question['position']}' class="list-no">#{question['position']}</span>
            <span question-no='#{question['position']}' class="option-text">#{question['question']}</span>
          </div>
        </div>
      """
    )
    $('.question-field').html questions

  setTimeResponses: (num) ->
    self = @
    content = ''
    keyTime = ''
    Object.keys(@stats[num]).map((key) ->
      keyTime = """<div class="date-time-pull-left"><strong>#{key}: __</strong></div>"""
      timeChoice = ''
      self.stats[num][key].map((time) ->
        timeChoice += """
          <span class="response">#{key} : #{time}</span>
        """
      )
      content += """
        <div class="date-time-container">
          #{keyTime}
          <div class="divider"></div>
          <div class="date-time-pull-right">#{timeChoice}</div>
        </div>
      """
    )
    $('.responses-time-wrapper').html content

  setDateResponses: (num) ->
    self = @
    content = ''
    keyDate = ''
    Object.keys(@stats[num]).map((key) ->
      keyDate = """<div class="date-time-pull-left"><strong>#{key}: __</strong></div>"""
      dayChoice = ''
      self.stats[num][key].map((day) ->
        dayChoice += """
          <span class="response">#{day}</span>
        """
      )
      content += """
        <div class="date-time-container">
          #{keyDate}
          <div class="divider"></div>
          <div class="date-time-pull-right">#{dayChoice}</div>
        </div>
      """
    )
    $('.responses-date-wrapper').html content

  setParagraphResponses: (num) ->
    self = @
    content = ''
    @stats[num].map((response) ->
      content += """
        <div class="paragraph-container">
          <div class="response">
            #{response}
          </div>
        </div>
      """
    )
    $('.responses-paragraph-wrapper').html content


  chartMapper: (type) ->
    chartTypeMap = {
      SurveyDateQuestion: 'date-question',
      SurveyTimeQuestion: 'time-question',
      SurveySelectQuestion: 'pie-chart-question',
      SurveyScaleQuestion: 'vertical-bar-question',
      SurveyParagraphQuestion: 'paragraph-question',
      SurveyCheckboxQuestion: 'horizontal-bar-question',
      SurveyPictureOptionQuestion: 'picture-pie-chart-question',
      SurveyMultipleChoiceQuestion: 'pie-chart-question',
      SurveyMultigridCheckboxQuestion: 'checkbox-bar-question',
      SurveyMultigridOptionQuestion: 'multichoice-bar-question',
      SurveyPictureCheckboxQuestion: 'picture-horizontal-bar-question',
    }
    return chartTypeMap[type]

  responseMapper: (type) ->
    responseTypeMap = {
      SurveyTimeQuestion: 'survey_time_responses',
      SurveyDateQuestion: 'survey_date_responses',
      SurveyScaleQuestion: 'survey_scale_responses',
      SurveySelectQuestion: 'survey_option_responses',
      SurveyCheckboxQuestion: 'survey_option_responses',
      SurveyParagraphQuestion: 'survey_paragraph_responses',
      SurveyPictureOptionQuestion: 'survey_option_responses',
      SurveyMultipleChoiceQuestion: 'survey_option_responses',
      SurveyPictureCheckboxQuestion: 'survey_option_responses',
      SurveyMultigridOptionQuestion: 'survey_grid_option_responses',
      SurveyMultigridCheckboxQuestion: 'survey_grid_option_responses',
    }
    return responseTypeMap[type]

  setResponseCount: () ->
    response_count = @surveyResponses.length
    modifier =
      if response_count == 1 then 'person'
      else 'people'
    $('.respondent-count').text("#{response_count} #{modifier} responded")
    respondents = ''
    @bootcampers.map((bootcamper) ->
      initials = bootcamper[1].slice(0,1) + bootcamper[2].slice(0,1)
      respondents += """
        <div class="item-container">
          <div class="respondent">
            <div class="close"></div>
            <span class="list-no">#{initials.toUpperCase()}</span>
            <span class="option-text">#{bootcamper[0]}</span>
          </div>
        </div>
      """
    )
    $('.respondents-field').html respondents

  displayEmptyPreview: ->
    $('.single-view-section').html ""
    $('.overview-section').html $('.empty-response-wrapper')

  aggregateStatFields: ->
    self = @
    unless @surveyResponses.length
      @displayEmptyPreview()
      return @toggleResponseButtons()
    $('.empty-response-wrapper').remove()
    @surveyQuestions.map((question) ->
      self.stats[question['position']] = self.aggregator(question, self.surveyResponses)
    )
    @initializeResponses()
    @clickQuestion(1)

  aggregator: (question, responses) ->
    self = @
    aggregate = {
      SurveyDateQuestion:(question, responses) -> self.dateStat(question, responses)
      SurveyTimeQuestion:(question, responses) -> self.timeStat(question, responses)
      SurveyScaleQuestion:(question, responses) -> self.scaleQuestionStat(question, responses)
      SurveyParagraphQuestion:(question, responses) -> self.paragraphStat(question, responses)
      SurveySelectQuestion:(question, responses) -> self.optionQuestionStat(question, responses)
      SurveyCheckboxQuestion: (question, responses) -> self.checkboxOptionStat(question, responses)
      SurveyPictureOptionQuestion:(question, responses) -> self.optionQuestionStat(question, responses)
      SurveyMultipleChoiceQuestion: (question, responses) -> self.optionQuestionStat(question, responses)
      SurveyPictureCheckboxQuestion:(question, responses) -> self.checkboxOptionStat(question, responses, true)
      SurveyMultigridOptionQuestion:(question, responses) -> self.multiGridQuestionStat(question, responses)
      SurveyMultigridCheckboxQuestion:(question, responses) -> self.multiGridQuestionStat(question, responses, true)
    }
    aggregate[question.type](question, responses)

  paragraphStat: (question, responses) ->
    paragraphMap = []
    paragraphResponses = []
    responses.map((respondent) ->
      respondent['survey_paragraph_responses'].map((paragraphResponse) ->
        paragraphResponses.push(paragraphResponse)
      )
    )
    paragraphMap = paragraphResponses.map((response) -> response.value)

  dateStat: (question, responses) ->
    dateMap = {}
    dateResponses = []
    responses.map((respondent) ->
      respondent['survey_date_responses'].map((dateResponse) ->
        dateResponses.push(dateResponse)
      )
    )
    dateResponses.map((response) ->
      tmp = response.value.split('-')
      day = tmp[2]
      month = tmp[1]
      year = tmp[0]
      prevState = dateMap["#{month}-#{year}"] || []
      dateMap["#{month}-#{year}"] = [prevState..., day] || [day]
    )
    return dateMap

  timeStat: (question, responses) ->
    timeMap = {}
    timeResponses = []
    responses.map((respondent) ->
      respondent['survey_time_responses'].map((timeResponse) ->
        timeResponses.push(timeResponse)
      )
    )
    timeResponses.map((response) ->
      tmp = new Date(response.value)
      minutes = tmp.getMinutes()
      hour = tmp.getHours()
      prevState = timeMap[hour] || []
      timeMap[hour] = [prevState..., minutes] || [minutes]
    )
    return timeMap

  multiGridQuestionStat: (question, responses, check=false) ->
    self = @
    gridResponses = []
    responses.map((respondent) ->
      respondent['survey_grid_option_responses'].map((response) ->
        if +response.question_id == +question.id
          gridResponses.push response
      )
    )
    options = []
    major = question['survey_options']['rows']
    minor = question['survey_options']['columns']
    question['survey_options']['columns'].map((option) ->
      options.push(option.option)
    )
    question['survey_options']['rows'].map((option) ->
      options.push(option.option)
    )
    colors = self.generateRandomColors(3)
    return [
      'Grid chart',
      if check then 'optionsDistributionCheckboxBar' else 'optionsDistributionMultipleChoiceBar',
      major.map((option) -> option.option),
      {
        datasets: minor.map((option, index) ->
          crossCount = {}
          gridResponses.map((response) ->
            if response.col_id == option.id
              crossCount[response.row_id] = crossCount[response.row_id] + 1 || 1
            else
              crossCount[response.row_id] = crossCount[response.row_id] || 0
          )
          data = Object.keys(crossCount).map((elem) -> crossCount[elem])
          return {
            label: option.option,
            data: data,
            backgroundColor: colors[index],
            borderWidth: 1
          }
        )
      }
    ]

  scaleQuestionStat: (question, responses) ->
    countMap = {}
    responseCount = responses.length
    range = []
    rangeData = []
    labels = []
    responses.map((respondent) ->
      respondent['survey_scale_responses'].map((response) ->
        countMap[response['value']] = countMap[response['value']] + 1 || 1
      )
    )
    for i in [question['scale'].min..question['scale'].max]
      range.push("#{i}")
      rangeData.push(countMap["#{i}"] || 0)

    labels = range.map((_, key) ->
      return "#{countMap["#{key + 1}"] || 0} (#{(countMap["#{key + 1}"] || 0) / responseCount * 100})%"
    )
    return [
      'optionsDistributionVerticalBar',
      'optionsDistributionVerticalBar',
      range,
      {
        datasets: [
          {
            data: rangeData,
            backgroundColor: @generateRandomColors(question['scale'].max),
            borderWidth: 1,
          }
        ],
        actualData: { firstLabel: labels }
      }
    ]

  optionQuestionStat: (question, responses) ->
    optionStats = @getOptionStats(question['id'], question['survey_options'], responses)
    return [
      "Options Chart",
      'optionsDistributionChart',
      optionStats.options,
      optionStats.optionPercentages,
      @generateRandomColors(question['survey_options'].length),
      0.5,
      optionStats.optionSums,
      question['survey_options'],
    ]

  checkboxOptionStat: (question, responses, image=false) ->
    optionStats = @getOptionStats(question['id'], question['survey_options'], responses)
    return [
      'optionsDistibutionHorizontalBar',
      if image then 'pictureOptionsDistributionHorizontalBar' else 'optionsDistributionHorizontalBar',
      {
        datasets: [
          {
            data: optionStats.optionPercentages,
            backgroundColor: @generateRandomColors(question['survey_options'].length),
          }
        ],
        actualData: { firstLabel: optionStats.optionPercentages.map((item, index) -> return "- (#{item}%)") }
      },
      optionStats.options,
      question['survey_options']
    ]
    
  getOptionStats: (questionId, surveyOptions, optionResponses) ->
    countMap = {}
    optionPercentages = []
    optionSums = []
    options = []
    self = @
    optionResponses.map((respondent) ->
      respondent['survey_option_responses'].map((response) ->
        if(+response.question_id == +questionId)
          countMap[response['option_id']] = (countMap[response['option_id']] + 1 || 1)
        else
          countMap[response['option_id']] = (countMap[response['option_id']] || 0)
      )
    )
    optionsMap = surveyOptions.map((optionItem) ->
      option =
        if optionItem.option_type == 'image' then self.processMediaLink(optionItem.option).base_name
        else optionItem.option
      {
        id: optionItem.id,
        option,
        count: countMap[optionItem.id]
      }
    )
    total = 0
    Object.keys(countMap).map((optionCount) ->
      total += +countMap[optionCount]
    )
    optionsMap.map((item) ->
      ratio = (item.count || 0) / total
      optionPercentages.push(ratio * 100)
      optionSums.push("(#{item.count || 0})")
      options.push(item.option)
    )
    { options, optionPercentages, optionSums }

  processMediaLink: (string) ->
    extractor_regex = /^(?:.*)\/(\w*).(\w+)$/gi
    processed_link = extractor_regex.exec(string)
    { base_name: processed_link[1], extension: processed_link[2] }

  toggleResponseButtons: () ->
    @resetView()
    $('#overview-btn').addClass('button-background-color').click(->
      $(".overview-section").show()
      $('.respondents').show()
      $(".single-view-section").hide()
    )

    $('#single-view-btn').click(->
      $(".overview-section").hide()
      $('.respondents').hide()
      $(".single-view-section").show()
    )

    $('.view-btn').on 'click', ->
      $(this).addClass('button-background-color').siblings().removeClass('button-background-color')

  resetView: () ->
    @hide [".view-pictures", ".checkbox-bar-wrapper", ".multichoice-bar-wrapper", ".piechart-wrapper",
      ".horizontal-bar-wrapper", ".vertical-bar-wrapper", '.checkbox-view-photos']
    #  ".single-view-section",

  hide: (handles) ->
    handles.map (handle) ->
      $(handle).hide()

  show: (handles) ->
    handles.map (handle) ->
      $(handle).show()

  generateRandomColors: (num) ->
    color_bank = [
      '#3359db', '#ffaf30', '#999999', '#7e0aed', '#4babaf', '#f30000',
      '#a200ff', '#dd9990', '#0e0aed', '#4ca0af', '#830000', '#02005f'
    ]
    color_hex = []
    for i in [1..num]
      color_hex.push(color_bank[+i])
    color_hex

  pieChartOptions: (num) ->
    @resetView()
    chart = @chart.pieChart(@stats[num]...)
    $("#optionsDistributionChartLegends").html(chart.generateLegend())

  scaleBarOption: (num) ->
    @resetView()
    chart = @chart.verticalBar(@stats[num]...)

  checkboxBarOption: (num) ->
    @resetView()
    chart = @chart.horizontalBar(@stats[num]...)

  multipleChoiceBarOption: (num) ->
    @resetView()
    chart = @chart.stackedVerticalBar(@stats[num]...)

  checkboxGridBarOption: (num) ->
    @resetView()
    chart = @chart.stackedVerticalBar(@stats[num]...)

  pictureMultipleChoiceOptions: (num) ->
    @resetView()
    pictures = @stats[num]
    chart = @chart.pieChart(@stats[num]...)
    $(".checkbox-view-photos").css({"bottom": "10.5rem"}) 
    $(".display-survey-picture").html """<div class="display-response-image">View images</div>"""

    $("#pictureOptionsDistributionChartLegends").html(chart.generateLegend())
    @adminViewSurveyImageResponse(pictures)

  pictureCheckboxBarOption: (num) ->
    @resetView()
    pictures = @stats[num]
    $(".display-survey-picture").html """<div class="display-response-image">View images</div>"""
    @adminViewSurveyCheckboxImageResponse(pictures)
    chart = @chart.horizontalBar(@stats[num]...)
    

  displayChartOptions: () ->
    self = @
    @clickQuestion(1)
    $('.chart-question').on 'click', (event) ->
      event.stopPropagation();
      question_number = +event.target.getAttribute('question-no')
      $('.question-responses-title').html "Question #{question_number} responses"
      self.currentQuestion = question_number
      self.getCurrentCamperResponse(self.currentCamper) if self.currentCamper
      $(this).removeClass('remove-background-color').addClass('add-background-color').siblings().addClass('remove-background-color')
      switch
        when $(this).hasClass('pie-chart-question') then self.mulitplechoiceDropdownQuestion(question_number)
        when $(this).hasClass('vertical-bar-question') then self.scaleQuestion(question_number)
        when $(this).hasClass('horizontal-bar-question') then self.checkboxQuestion(question_number)
        when $(this).hasClass('multichoice-bar-question') then self.multiplechoiceGridQuestion(question_number)
        when $(this).hasClass('checkbox-bar-question') then self.checkboxGridQuestion(question_number)
        when $(this).hasClass('picture-horizontal-bar-question') then self.pictureCheckboxQuestion(question_number)
        when $(this).hasClass('picture-pie-chart-question') then self.pictureMultipleChoiceQuestion(question_number)
        when $(this).hasClass('date-question') then self.dateQuestion(question_number)
        when $(this).hasClass('time-question') then self.timeQuestion(question_number)
        when $(this).hasClass('paragraph-question') then self.paragraphQuestion(question_number)
        else
          return

  clickQuestion: (num) ->
    $(document).ready(->
      $('.question-'+num).click()
    )

  dateQuestion: (num) ->
    @setDateResponses(num)
    @hide [
      ".piechart-wrapper", '.responses-time-wrapper',
      '.multichoice-bar-wrapper', '.responses-paragraph-wrapper',
      '.checkbox-view-photos', '.vertical-bar-wrapper', '.horizontal-bar-wrapper',
      '.checkbox-bar-wrapper', '.picture-piechart-wrapper', '.picture-horizontal-bar-wrapper',
    ]
    @show ['.responses-date-wrapper']

  timeQuestion: (num) ->
    @setTimeResponses(num)
    @hide [
      ".piechart-wrapper", '.responses-date-wrapper',
      '.multichoice-bar-wrapper','.responses-paragraph-wrapper',
      '.checkbox-view-photos', '.vertical-bar-wrapper', '.horizontal-bar-wrapper',
      '.checkbox-bar-wrapper', '.picture-piechart-wrapper', '.picture-horizontal-bar-wrapper',
    ]
    @show ['.responses-time-wrapper']

  paragraphQuestion: (num) ->
    @setParagraphResponses(num)
    @hide [
      ".piechart-wrapper", '.responses-date-wrapper',
      '.multichoice-bar-wrapper', '.responses-time-wrapper',
      '.checkbox-view-photos', '.vertical-bar-wrapper', '.horizontal-bar-wrapper',
      '.checkbox-bar-wrapper', '.picture-piechart-wrapper', '.picture-horizontal-bar-wrapper',
    ]
    @show ['.responses-paragraph-wrapper']

  mulitplechoiceDropdownQuestion: (num) ->
    @pieChartOptions(num)
    @hide [
      '.multichoice-bar-wrapper', '.responses-time-wrapper',
      '.responses-date-wrapper', '.responses-paragraph-wrapper',
      '.checkbox-view-photos', '.vertical-bar-wrapper', '.horizontal-bar-wrapper',
      '.checkbox-bar-wrapper', '.picture-piechart-wrapper', '.picture-horizontal-bar-wrapper',
    ]
    @show [".piechart-wrapper"]

  scaleQuestion: (num) ->
    @scaleBarOption(num)
    @hide [
      '.responses-paragraph-wrapper',
      '.checkbox-view-photos',  ".piechart-wrapper", '.horizontal-bar-wrapper',
      '.multichoice-bar-wrapper', '.responses-time-wrapper', '.checkbox-bar-wrapper',
      '.picture-piechart-wrapper', '.picture-horizontal-bar-wrapper', '.responses-date-wrapper',
    ]
    @show ['.vertical-bar-wrapper']

  checkboxQuestion: (num) ->
    @checkboxBarOption(num)
    @hide [
      '.picture-horizontal-bar-wrapper','.responses-time-wrapper',
      '.checkbox-view-photos',  ".piechart-wrapper", '.vertical-bar-wrapper',
      '.checkbox-bar-wrapper', '.picture-multiple-bar-wrapper', '.picture-piechart-wrapper',
      '.multichoice-bar-wrapper', '.responses-date-wrapper', '.responses-paragraph-wrapper',
    ]
    @show ['.horizontal-bar-wrapper']

  multiplechoiceGridQuestion: (num) ->
    @multipleChoiceBarOption(num)
    @hide [
      '.checkbox-view-photos',  ".piechart-wrapper",'.vertical-bar-wrapper',
      '.horizontal-bar-wrapper','.responses-time-wrapper', '.checkbox-bar-wrapper',
      '.picture-piechart-wrapper', '.picture-horizontal-bar-wrapper', '.responses-date-wrapper',
      '.responses-paragraph-wrapper',
    ]
    @show ['.multichoice-bar-wrapper']

  checkboxGridQuestion: (num) ->
    @checkboxGridBarOption(num)
    @hide [
      '.checkbox-view-photos', '.multichoice-bar-wrapper', ".horizontal-bar-wrapper",
      ".horizontal-bar-wrapper",'.responses-time-wrapper',
      ".piechart-wrapper",'.picture-piechart-wrapper', '.vertical-bar-wrapper',
      '.picture-horizontal-bar-wrapper', '.responses-date-wrapper', '.responses-paragraph-wrapper',
    ]
    @show ['.checkbox-bar-wrapper']

  pictureMultipleChoiceQuestion: (num) ->
    @pictureMultipleChoiceOptions(num)
    @hide [
      '.checkbox-view-photos', '.multichoice-bar-wrapper', ".horizontal-bar-wrapper",
      ".horizontal-bar-wrapper", '.responses-time-wrapper', ".piechart-wrapper",
      '.picture-horizontal-bar-wrapper','.vertical-bar-wrapper', '.checkbox-bar-wrapper',
      '.responses-date-wrapper', '.responses-paragraph-wrapper',
    ]
    @show ['.picture-piechart-wrapper', '.piechart-wrapper','.checkbox-view-photos']

  pictureCheckboxQuestion: (num) ->
    @pictureCheckboxBarOption(num)
    @hide [
      '.checkbox-view-photos', '.multichoice-bar-wrapper', ".horizontal-bar-wrapper",
      ".horizontal-bar-wrapper", '.responses-time-wrapper', '.checkbox-view-photos',
      ".piechart-wrapper",'.picture-piechart-wrapper', '.vertical-bar-wrapper',
      '.checkbox-bar-wrapper', '.responses-date-wrapper', '.responses-paragraph-wrapper',
    ]
    @show ['.picture-horizontal-bar-wrapper', '.checkbox-view-photos']

  openSurveyResponseModal: ->
    self = @
    $('#share-report-btn').on 'click', ->
      self.surveyResponseModal.open()
      self.getAllAdmin((response) -> (
          message = 'There was an error'
          self.flashErrorMessage message
        )).then(
        (response) ->
          self.recipients = response.emails
          self.populateRecipients()
     )
    $(".share-report-btn").eq(1).on 'click', ->
      if self.survey_recipients.length
        self.initShareSurveyReport(self.survey_recipients)
        self.surveyResponseModal.close()
      else
        $("#survey-report-error").css("display": "block", "top": "1em").html("Please select at least one recipient")

    $('#close-share-modal').on 'click', ->
      self.surveyResponseModal.close()

  initializeResponseModal: ->
    @openSurveyResponseModal()

  setActiveIcon: (elem) ->
    $("##{elem}-active").show()
    $("##{elem}").hide()
    ['pdf-icon', 'csv-icon'].filter((icon) ->
      icon != elem
    ).map((icon) ->
      $("##{icon}-active").hide()
      $("##{icon}").show()
    )

  registerActiveClass: (elem) ->
    $("##{elem}").addClass('is-active')
    ['link-share', 'mail-share', 'frame-share', 'pdf-download', 'csv-download'].filter((icon) ->
      icon != elem
    ).map((icon) ->
      $("##{icon}").removeClass('is-active')
    )

  flashSuccessMessage: (message) ->
    @toastMessage(message, 'success')
    $('.respond-submit-btn').removeClass('is-success').addClass('disabled')

  flashErrorMessage: (message) ->
    @toastMessage(message, 'error')
    $('.respond-submit-btn').removeClass('disabled').addClass('is-success')

  toastMessage: (message, status) ->
    $('.toast').messageToast.start(message, status)

  initShareSurveyReport: (emails) ->
    self = @
    program_id = localStorage.getItem('programId')
    survey_response_link = $(location).attr("href") + "?programId=#{program_id}"
    adminEmails = JSON.stringify({ emails: emails, url: survey_response_link })
    self.shareSurvey(adminEmails,  (response) -> (
          message = 'There was an error sending the mail'
          self.flashErrorMessage message
        )).then(
        (response) -> (self.flashSuccessMessage response.message)
      )

  populateRecipients: () ->
    self = @
    options = ''
    self.recipients.forEach((option) ->
      already_selected = self.survey_recipients.find((recipient) ->
        recipient == option
      )
      return if already_selected
      options += """
        <div class='option'>
          <p>#{option}</p>
          <input type='hidden' value='#{option}'/>
        </div>"""
    )
    $('.cycle-options-list').html(options)

    $('#main-response-modal .option').on 'click', -> (
      selected_email = $(this).find('input').val()
      selected_recipient = self.recipients.find((recipient) ->
        recipient == selected_email
      )
      self.survey_recipients.unshift(selected_recipient)
      options = ''
      self.survey_recipients.forEach((recipient) -> (
        options += """
          <li>
            #{recipient}
            <span data-target="#{recipient}" class="close">&times;</span>
          </li>
        """
      ))
      $('#main-response-modal .selected-cycles').html(options)
      $('#main-response-modal .selected-cycles .close').on 'click', -> (
        remove_email = $(this).data('target')
        self.survey_recipients =
          self.survey_recipients.filter((recipient) -> recipient != remove_email)
        $(this).parent().remove()
        self.populateRecipients()
      )
      self.populateRecipients()
    )

  adminViewSurveyImageResponse: (pictures)->
    image_list = ""
    pictures[7].map (picture) ->
      image_list += """
        <li class='option-image-list-item'>
          <h4>#{picture.option.split("/")[4]}</h4>
          <img src='#{picture.option}' alt='#{picture.option_type}' image-id=#{picture.id} class='preview-image-placeholder'>
        </li>
      """
    display_image_list = """
      <ul class='image-list'>
      #{image_list}
      </ul>
    """
    @displaySurveyImage(display_image_list)

  adminViewSurveyCheckboxImageResponse: (pictures) ->
    image_list = ""
    pictures[4].map (picture) ->
      image_list += """
        <li class='option-image-list-item'>
          <h4>#{picture.option.split("/")[4]}</h4>
          <img src='#{picture.option}' alt='#{picture.option_type}' image-id=#{picture.id} class='preview-image-placeholder'>
        </li>
      """
    display_image_list = """
      <ul class='image-list'>
      #{image_list}
      </ul>
    """
    @displaySurveyImage(display_image_list)


  displaySurveyImage: (display_image_list) ->
    self = @
    $(".display-response-image").off("click").click ->
      $(".preview-modal-image-display-content").html display_image_list
      self.previewSurveyResponseImageModal.open()
      
    $("#preview-close").click ->
      self.previewSurveyResponseImageModal.close()
    

