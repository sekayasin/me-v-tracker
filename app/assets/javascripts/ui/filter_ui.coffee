class Filter.UI
  constructor: (@fetchFilterParams, @fetchCycles, @fetchFacilitators, @fetchLearners) ->
    @submissionUI = new Submissions.UI()
    @contentsPerPage = @submissionUI.contentsPerPage
    @loaderUI = new Loader.UI()
    @pagination = new PaginationControl.UI()
    @filter = {
      default: false,
      filters: {
        locations: [],
        cycles: [],
        lfas_week_one: [],
        lfas_week_two: [],
      }
    }
  
  initializePagination: (total_count) =>
    @pagination.initialize(
      total_count, @fetchLearners,
      @generateLearnersCards, @contentsPerPage,
      @filter.filters,
      ".pagination-control-submissions"
    )

  populateLearners: =>
    savedFilter = JSON.parse(localStorage.getItem('admin_filters'))
    filterParams = savedFilter || {}
    if pageUrl[pageUrl.length - 1] == "submissions"
      page = 1
      @loaderUI.show()
      @fetchLearners(@contentsPerPage, page, filterParams).then((response) =>
        if savedFilter?
          $(".clear-btn").prop("disabled", false)
          $(".clear-btn").css( "cursor", "pointer" )
        else
          $(".clear-btn").prop("disabled", true) unless savedFilter?
          $(".clear-btn").css( "cursor", "not-allowed" )
        $("#filter-count").html("Showing #{response.submissions_count} learners in result")
        @afterLearnersFetch(response))

  afterLearnersFetch: (response) =>
    @loaderUI.hide()
    if response.submissions_count
      @generateLearnersCards(response.paginated_data, response.submissions_count)
    else
      @initializePagination(0)
      learnerCardsContainer = $(".learners-submissions-cards")
      learnerCardsContainer.html("")
      $('.filter-container').html('')
      learnerCardsContainer.append(
        "<h2 class='center-blank-state-text'>No data to show :(</h2>")

  generateLearnersCards: (submissions, count) =>
    @initializePagination(count)
    learnerCardsContainer = $(".learners-submissions-cards")
    learnerCardsContainer.html("")
    for learner in submissions
      learnerCard =
        "<a class='learner-overview-container' id='#{learner.learner_email}' href='/submissions/#{learner.learner_program_id}'>" +
        "<div class='learner-submission-overview'>"
      if learner.has_unreviewed_output
        learnerCard +=
          "<div class='blue-dot'></div>"
      learnerCard +=
        "<img src='#{learner.image}' alt='learner image' class='learner-submission-image'/>" +
        "<div class='learner-submission-name'>#{learner.learner_name}</div>" +
        "<div class='learner-submission-count'>" +
        "#{learner.submissions}/#{learner.total_submission}" +
        "<br /> submissions" +
        "</div></div></a>"
      learnerCardsContainer.append(learnerCard)
  
  displayFilterPane: ->
    if $('.filter-container').is(':visible')
      $('.learners-submission-container').addClass('display-filter-pane')
      $('.learner-overview-container').attr('id', 'learner-overview-container')

  initializeFilter: ->
    @fetchFilterParams(@displayData)
    @populateLocation()
    @listenForScreenChange()
    @getCheckedValues()
    @toggleSelectAllCheckbox()
    $("#location-filter").click () =>
      @toggleDropdown('#location-filter', '#location-box')
    $("#cycle-filter").click () =>
      @toggleDropdown("#cycle-filter", '#cycle-box')
      if @emptyDropdown('#cycle-list')
        @hideCycleOptions('#cycle-list', '#cycle-box', ".search")
    $("#first-lfa-filter").click () =>
      @toggleDropdown("#first-lfa-filter", '#first-lfa-box')
      if @emptyDropdown('#first-lfa-list')
        @hideCycleOptions('#first-lfa-list', '#first-lfa-box', ".search-lfa")
    $("#sec-lfa-filter").click () =>
      @toggleDropdown("#sec-lfa-filter", '#sec-lfa-box')
      if @emptyDropdown('#sec-lfa-list')
        @hideCycleOptions('#sec-lfa-list', '#sec-lfa-box', ".search-lfa")
    $(".filter-btn").click ( =>
      @saveFilterParamsToStorage()
      @populateLearners())
    $(".clear-btn").click ( => @clearFilterOptions())

  toggleDropdown: (dropDownArrowId, displayCheckboxId) =>
    $(".error-text").addClass('hidden')
    arrowIcon = $("#{dropDownArrowId} > .arrow-icon")
    unless arrowIcon.hasClass("arrow-down-icon")
      arrowIcon.addClass("arrow-down-icon")
      $("#{displayCheckboxId} > .wrapper").addClass("hidden")
    else
      arrowIcon.removeClass("arrow-down-icon")
      arrowIcon.addClass("arrow-up-icon")
      @handleSelectBoxClick(displayCheckboxId)

  populateLocation: () ->
     @fetchFilterParams()
     .then((data) =>
      @generateOptionDropdown(data.centers.sort(), "#location-list") if data.centers?)

  displayCycles: (centers) ->
    @fetchCycles(centers)
    .then((data) =>
      if data.length == 0
        $('#cycle-search').html('No cycle found for this location')
      else
        $('#cycle-search').html('Select location to search')
      @generateCycleDropdown(data, "#cycle-list", "#cycle-box", "#cycle-search", "#cycle-filter"))
   
  getCheckedValues: ->
    centers = { centers: @filter.filters.locations }
    lfaOptions = { location: @filter.filters.locations, cycle: @filter.filters.cycles }
    getAllOptions = 'Select All'
    $('.filter-container').on 'click', '.filter-item', (event) =>
      parentId = $(event.target).parent().parent().parent().attr('id')
      checkboxId = $(event.target).attr('id')
      checkboxValue = $(event.target).parent().parent().attr('data-value')
      if $("##{checkboxId}").is(':checked')
        @populateAllList(parentId, @getClickedArray(parentId)) if checkboxValue == getAllOptions
        if checkboxValue == getAllOptions && parentId == 'location-list'
          @displayCycles(centers)
          return
        else
          @getFilterParams(@getClickedArray(parentId), checkboxId)
          if @filter.filters.locations.length > 0 && parentId == 'location-list'
            @displayCycles(centers)
        @displayFacilitators(lfaOptions) if parentId == 'cycle-list'
      
      else
        @unselectAllValues(@getClickedArray(parentId), parentId) if checkboxValue == getAllOptions
        unless checkboxValue == getAllOptions
          @unselectSingleItem(@getClickedArray(parentId), checkboxId, parentId)
          @displayFacilitators(lfaOptions) if parentId == 'cycle-list'

  getClickedArray: (clickedId) ->
    switch clickedId
      when 'location-list' then checkedArray = @filter.filters.locations
      when 'cycle-list' then checkedArray = @filter.filters.cycles
      when 'first-lfa-list' then checkedArray = @filter.filters.lfas_week_one
      when 'sec-lfa-list' then checkedArray = @filter.filters.lfas_week_two

  populateAllList: (parentId, filterArray) ->
    selectAllBoxClass = 'select-all'
    $("##{parentId} input:checkbox").each(() ->
      filterArray.push($(this).attr('id')) unless $(this).attr('values') == selectAllBoxClass)

  unselectSingleItem: (array, clickedValue, parentId) ->
    $(".all").prop('checked', false)
    @clearCycleOption(clickedValue) if parentId == 'location-list'
    index = $.inArray clickedValue, array
    array.splice(index, 1) if index > -1

  getFilterParams: (array, checkboxValue) ->
    selectAllIds = ['lfa-one', 'cycles', 'lfa-two']
    if selectAllIds.indexOf(checkboxValue) > -1
      return
    else if array && array.indexOf(checkboxValue) == -1
      array.push(checkboxValue)

  unselectAllValues: (array, parentId) ->
    array.length = 0
    if parentId == 'location-list'
      @filter.filters.cycles.length = 0
      @emptyLfaOptions()
      @hideCycleOptions('#cycle-list', '#cycle-box', '#cycle-search')
      @hideCycleOptions('#first-lfa-list', '#first-lfa-box', '.search')
      @hideCycleOptions('#sec-lfa-list', '#sec-lfa-box', '.search')
    @emptyLfaOptions() if parentId == 'cycle-list'

  clearCycleOption: (clickedValue) ->
    self = @
    $("#cycle-list li").each(() ->
      cycleValue = $(this).text().trim() if !!$(this).text()
      clickedCycle =  cycleValue.substr(0, cycleValue.indexOf(' ')) if !!cycleValue
      if clickedCycle == clickedValue
        index = $.inArray $(this).attr('cycleId').trim(), self.filter.filters.cycles
        self.filter.filters.cycles.splice(index, 1) if index > -1
        $('li[data-value="' + cycleValue + '"]').remove())
    if @emptyDropdown('#cycle-list')
      self.hideCycleOptions('#cycle-list', '#cycle-box', '#cycle-search')
      self.hideCycleOptions('#first-lfa-list', '#first-lfa-box', '.search-lfa')
      self.hideCycleOptions('#sec-lfa-list', '#sec-lfa-box', '.search-lfa')
      $('#cycle-search').html('Select location to search')
      self.emptyLfaOptions()

  emptyLfaOptions: ->
    @filter.filters.lfas_week_one.length = 0
    @filter.filters.lfas_week_two.length = 0

  hideCycleOptions: (listId, dropdownId, searchId) ->
    $("#{listId}").addClass('hidden')
    $("#{searchId}").removeClass('hidden')
    $("#{dropdownId}").find('.mdl-textfield').addClass('hidden')

  emptyDropdown: (dropdownId) -> $("#{dropdownId}").children().length == 1
 
  displayFacilitators: (lfaOptions) ->
    @fetchFacilitators(lfaOptions)
    .then((data) =>
      if data.week_one?
        @generateCycleDropdown(data.week_one, '#first-lfa-list', '#first-lfa-box', ".search-lfa")
      if data.week_two?
        @generateCycleDropdown(data.week_two, '#sec-lfa-list', '#sec-lfa-box', ".search-lfa"))

  generateCycleDropdown: (options, optionId, wrapperId, searchId) =>
    $("#{optionId}").removeClass('hidden')
    $("#{optionId} li:not(:first)").remove()
    $("#{searchId}").addClass('hidden')
    list = $("#{optionId}")
    list.find('#cycle-all').removeClass('hidden')
    list.find('#lfa-one-all').removeClass('hidden')
    list.find('#lfa-two-all').removeClass('hidden')
    facilitatorDataLength = 2
    for option in options
      if options[0].length == facilitatorDataLength
        list.append(@lfaListItem(option[0], option[1]))
      else
        cycleNo = option[0]
        cycleId = option[1]
        center = option[2]
        cycle = "#{center} (#{cycleNo})"
        list.append(@lfaListItem(cycle, option[1]))
    $("#{wrapperId}").find('.mdl-textfield').removeClass('hidden')
    @setCheckboxOnReload(optionId)

  generateOptionDropdown: (options, listId, checkboxId) =>
    list = $("#{listId}")
    if list.children().length <= 1 && options?
      for option in options
        list.append(@locationListItem(option))
    @setCheckboxOnReload("#location-filter")

  lfaListItem: (displayData, checkboxId, option) ->
    """
      <li class="list-options" cycleId="#{checkboxId} "data-value="#{displayData}">
        <label class='checkbox-label'> #{displayData}
          <input type="checkbox" id="#{checkboxId}" class="filter-item #{displayData}"/>
          <span class="checkmark"></span>
        </label>
      </li>
    """
  locationListItem: (displayData) ->
    """
      <li class="list-options option-data" cycleId="#{displayData} "data-value="#{displayData}">
        <label class='checkbox-label'> #{displayData}
          <input type="checkbox" id="#{displayData}" class="filter-item #{displayData}"/>
          <span class="checkmark"></span>
        </label>
      </li>
    """

  listenForScreenChange: () ->
    smallScreenWidth = 425
    unless $(window).width() > smallScreenWidth
      $("#filter-small-main").append($(".filter-container"))
    window.addEventListener('resize', (event) ->
      unless $(window).width() > smallScreenWidth
        $("#filter-container").remove()
        $("#filter-small-main").append($(".filter-container"))
      else
        $("#filter-container").remove()
        $("#filter-main").append($(".filter-container")))

  handleSelectBoxClick: (currentId) =>
    @displayBox(currentId)
    selectBoxIds = ["#location-box", "#cycle-box", "#first-lfa-box", "#sec-lfa-box"]
    @hideCheckbox id for id in selectBoxIds when currentId isnt id

  displayBox: (displayCheckboxId) ->
    $("#{displayCheckboxId} > .wrapper").removeClass("hidden")

  hideCheckbox: (displayCheckboxId) ->
    $("#{displayCheckboxId} > .wrapper").addClass("hidden")
    $("#{displayCheckboxId} > .option-box > .arrow-icon").addClass("arrow-down-icon")

  toggleSelectAllCheckbox: (selectboxId) ->
    $("#location-list").find(".filter-item").click(() ->
      $( '#location-list input[type="checkbox"]' ).prop('checked', this.checked))
    $("#cycle-list").find(".filter-item").click(() ->
      $('#cycle-list input[type="checkbox"]' ).prop('checked', this.checked))
    $("#first-lfa-list").find(".filter-item").click(() ->
      $('#first-lfa-list input[type="checkbox"]' ).prop('checked', this.checked))
    $("#sec-lfa-list").find(".filter-item").click(() ->
      $('#sec-lfa-list input[type="checkbox"]' ).prop('checked', this.checked))

  filterDropdowns: =>
    self = @
    $("#search-cycle").on("change paste keyup", () ->
      searchValue = $(this).val()
      self.searchDropdownOptions(searchValue, '#cycle-list'))
    $("#search-lfa-one").on("change paste keyup", () ->
      searchValue = $(this).val().toLowerCase()
      self.searchDropdownOptions(searchValue, '#first-lfa-list'))
    $("#search-lfa-two").on("change paste keyup", () ->
      searchValue = $(this).val().toLowerCase()
      self.searchDropdownOptions(searchValue, '#sec-lfa-list'))

  searchDropdownOptions: (searchVal, listItems) ->
    errorMessage =  $('.error-text')
    options = $("#{listItems}")
    errorMessage.addClass("hidden")
    options.find('li').show()
    options.find('li').not(':contains(' + searchVal + ')').hide()
    if options.children(':visible').length > 0
      $(".list-checkbox").show()
    else
      errorMessage.removeClass("hidden")

  clearFilterOptions: ->
    $(".filter-item").prop('checked', false)
    localStorage.removeItem('admin_filters') if localStorage.getItem('admin_filters')?
    localStorage.removeItem('checkboxOptions') if localStorage.getItem('checkboxOptions')?
    @filter.filters[option].length = 0 for option of @filter.filters
    @populateLearners()
  
  saveFilterParamsToStorage: ->
    localStorage.removeItem('admin_filters') if localStorage.getItem('admin_filters')?
    localStorage.removeItem('checkboxOptions') if localStorage.getItem('checkboxOptions')?
    localStorage.setItem('admin_filters', JSON.stringify(@filter))
    localStorage.setItem('checkboxOptions', JSON.stringify(@filter.filters))
  
  setCheckboxOnReload: (dropdownId) =>
    switch dropdownId
      when '#location-filter' then @setCheckboxClick('locations')
      when '#cycle-list' then @setCheckboxClick('cycles')
      when '#first-lfa-list' then @setCheckboxClick('lfas_week_one')
      when '#sec-lfa-list' then @setCheckboxClick('lfas_week_two')

  setCheckboxClick: (dropdownId) ->
    savedCheckboxParams = JSON.parse(localStorage.getItem('checkboxOptions'))
    if savedCheckboxParams? && savedCheckboxParams[dropdownId].length > 0
      $("##{checkboxId}").click() for checkboxId in savedCheckboxParams[dropdownId]
      
