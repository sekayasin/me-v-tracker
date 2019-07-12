class Search.UI
  getModifier: =>
    $(".modifier").html().split(" ")[1]

  getSearchQuery: (type) =>
    if type == "desktop"
      return $(".search-container > input").val().trim()
    if type == "mobile"
      return $(".mobile-search-container > input").val().trim()

  showModifierError: =>
    $(".modifier-error").html("Please select a modifier")
    
  clearModifierError: =>
    $(".modifier-error").html("")

  showSearchQueryError: =>
    $(".modifier-error").html("Please enter a search term")

  clearSearchQueryError: =>
    $(".modifier-error").html("")
  
  checkSubmitMethod: (saveSearchDetails, redirectSearch) =>
    self = @
    $(".search-container > input").on 'keydown', (event) ->
      if event.keyCode == 13
        self.handleSubmit(saveSearchDetails, redirectSearch, "desktop")

    $(".mobile-search-container > input").on 'keydown', (event) ->
      if event.keyCode == 13
        self.handleSubmit(saveSearchDetails, redirectSearch, "mobile")
    
    $(".search-icon").click ->
      self.handleSubmit(saveSearchDetails, redirectSearch, "desktop")

    $(".mobile-search-icon").click ->
      self.handleSubmit(saveSearchDetails, redirectSearch, "mobile")

  handleSubmit: (saveSearchDetails, redirectSearch, type) =>
    self = @
    if !self.getModifier()
      self.showModifierError()
      $(".modifiers-list").show()
    else if !self.getSearchQuery(type)
      self.showSearchQueryError()
      $(".modifiers-list").show()
    else
      modifier = self.getModifier()
      if type == "desktop"
        searchQuery = self.getSearchQuery("desktop")
      if type == "mobile"
        searchQuery = self.getSearchQuery("mobile")
      saveSearchDetails(modifier, searchQuery)
      redirectSearch(modifier, searchQuery)

  handleSearch: =>
    self = @
    $(".search-box").on 'click', (event)  ->
      event.stopPropagation()
      if !self.getModifier()
        $(".modifiers-list").show()

    # close dropdown if any part of the page is clicked
    $(document).click ->
      $(".modifiers-list").hide()

  handleModifierChange: (triggerClass, type) =>
    self = @
    $(triggerClass).click ->
      currentModifier = $(this).html()
      $(".modifier").html currentModifier
      $(".modifiers-list").hide()
      if type == "desktop"
        $(".search-input").css("width", "155px")
        $(".search-input").focus()
      if type == 'mobile'
        $(".mobile-search-container > input").addClass("input-with-modifier")
        $(".mobile-search-container > input").focus()

  handleModifierClick: (triggerClass) =>
    self = @ 
    $(triggerClass).click ->
      self.clearModifierError()
      self.clearSearchQueryError()
      $(".modifiers-list").toggle()

  updateSearchDetails: (searchDetails) =>
    $(".modifier").html "In: " + searchDetails.modifier
    $(".search-container > input").val searchDetails.query
    $(".mobile-search-container > input").val searchDetails.query
    $(".search-input").css("width", "155px")
    $(".mobile-search-container > input").addClass("input-with-modifier")
