class Search.App
  constructor: ->
    @ui = new Search.UI

  start: =>
    @ui.handleSearch()
    @persistSearchDetails()
    @ui.checkSubmitMethod(@saveSearchDetails, @redirectSearch)
    @ui.handleModifierClick(".current-modifier")
    @ui.handleModifierClick(".mobile-current-modifier")
    @ui.handleModifierChange(".modifiers-dropdown ul li", "desktop")
    @ui.handleModifierChange(".mobile-modifiers-dropdown ul li", "mobile")

  redirectSearch: (modifier, searchQuery) =>
    if modifier == "Curriculum"
      @getCurriculumSearchResult(searchQuery)
    if modifier == "Learners"
      @getLearnersSearchResult(searchQuery)
    if modifier == "Support"
      @getSupportSearchResult(searchQuery)

  getCurriculumSearchResult: (searchQuery) =>
    window.location = "/curriculum?search=#{searchQuery}"

  getLearnersSearchResult: (searchQuery) =>
    programId = localStorage.getItem('programId')
    window.location = "/learners?program_id=#{programId}&search=#{searchQuery}"

  getSupportSearchResult: (searchQuery) =>
    window.location = "/support?search=#{searchQuery}"

  persistSearchDetails: =>
    if window.location.search.includes("search")
      searchDetails = JSON.parse(window.localStorage.getItem('searchDetails'))
      @ui.updateSearchDetails(searchDetails)

  saveSearchDetails: (modifier, query) =>
    searchDetails = {
      "modifier": modifier,
      "query": query
    }
    window.localStorage.setItem('searchDetails', JSON.stringify(searchDetails));
