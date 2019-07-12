class SurveyV2.Initial.UI
    constructor: (api, surveyDuplication, preview, initDeleteModal, initEditModal) ->
        @getSurveysV2 = api
        @surveyEditUI = surveyDuplication
        @openSurveyPreviewModal = preview
        @initializeSurveyDeleteModal = initDeleteModal
        @initializeSurveyEditModal = initEditModal
        @surveysCount = 0
        @contentPerPage = 15
        @surveyPreviewModal = new Modal.App('#survey-v2-preview-modal', 672, 672, 598, 598)
        @pagination = new PaginationControl.UI()
        @helpers = new Helpers.UI()
        @surveyModal = new SurveyV2.UI()

    initializeGetSurvey: =>
        self = @
        @getSurveysV2(self.contentPerPage, self.pagination.page)
            .then((data) -> (
                return unless data.admin
                self.admin = data.admin
                surveyData = data.paginated_data
                self.surveysCount = data.surveys_count
                self.pagination.initialize(
                    self.surveysCount, self.getSurveysV2,
                    self.populateTable, self.contentPerPage,
                    {}, ".pagination-control.surveys-two-pagination"
                )
                self.populateTable(surveyData)
            ))

    populateTable: (surveyData) =>
        self = @
        return unless self.admin
        $("#surveys-count").html "#{@pluralize(self.surveysCount, 'Survey')}" 
        $(".surveys-grid").html("").append(
            "<div class='survey-new-card' id='new-survey-btn'>
            <div class='add-icon'></div>
                <p>Create a Survey</p>
            </div>"
        )
        $(".survey-new-card").click ->
            window.location.href = '/surveys-v2/setup'

        if self.surveysCount == 0
            $(".dash-main").html("").append(
                "<div class='empty-survey'>
                <div class='empty-image'></div>
                <p>No Surveys have been created</p>
                <a href='/surveys-v2/setup' class='new-survey-btn' id='new-survey-btn'> Create a Survey</a>
                </div>"
            )

        surveyData.forEach( (surveys) =>
            self.populateSurveyCard(surveys)
        )

    pluralize: (count, val) ->
      if count == 1
        return "#{count} #{val}"
      return "#{count} #{val}s"

    populateSurveyCard: (surveys) ->
        self = @
        return unless self.surveysCount > 0
        modifier =
            if surveys.survey_responses_count == 1
              'Response'
            else
              'Responses'
        status = surveys.status
        if status == "archived"
            status = "on hold"
        surveyDetails = """
            <div class="survey-card" id=#{surveys.id} data-survey_id="#{surveys.id}">
                    <div class="body survey-card-body">
                    <div class="title">#{@helpers.capitalizeSurvey(@helpers.truncateTitle(surveys.title))}</div>
                    <div class="survey-status">#{ @helpers.capitalizeSurvey(status)}</div>
                    <div class="time">
                      <div class="eye-icon"></div>
                      <span id="rem-time">#{moment(Date.parse(surveys.created_at)).fromNow()}</span>
                    </div>
                    </div>
                    <div class="foot">
                    <div class="resp">#{surveys.survey_responses_count} #{modifier}</div>
                    <div class="more-icon">
                        <ul class="drop-option">
                            #{checkDropDownStatus(surveys)}
                        </ul>
                    </div>
                    </div>
            </div>
        """
        $(".surveys-grid").append(surveyDetails)
        self.surveyEditUI.initializeSurveyDuplication()
        self.initializeSurveyDeleteModal()
        self.initializeSurveyEditModal()
        self.openSurveyPreviewModal()


    checkDropDownStatus = (surveys, surveys_id) ->
        if surveys.status in ["published", "archived"] and surveys.survey_responses_count > 0
            """
            <li class="drop-item"><a href="/surveys-v2/responses/#{surveys.id}">View Responses</a></li>
            <li class="drop-item" id="edit-form"><a class="edit" data-survey_id="#{surveys.id}">Edit Survey</a></li>
            <li class="drop-item new_survey_duplicate_btn" data-survey_id="#{surveys.id}">
                <a href="#" data-survey_id="#{surveys.id}">
                Duplicate
                </a>
            </li>
            <li class="drop-item"><a data-survey_id="#{surveys.id}" class="delete">Delete</a></li>
            """
        else
            """
            <li class="drop-item" id="edit-form"><a href="/surveys-v2/#{surveys.id}/edit">Edit Survey</a></li>
            <li class="drop-item new_survey_duplicate_btn" data-survey_id="#{surveys.id}">
                <a href="#" data-survey_id="#{surveys.id}">
                Duplicate
                </a>
            </li>
            <li class="drop-item"><a data-survey_id="#{surveys.id}" class="delete">Delete</a></li>
            """
