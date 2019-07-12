class PaginationControl.UI
  constructor: ->
    @loaderUI = new Loader.UI()
    @page = 1
    @contentPerPage = 10
    @contentCount = 0
    @totalPages = 0
    @allResult = {}
    @filter = {}
    @target = ".pagination-control"

  initialize: (contentCount, contentApi, populateTable, contentPerPage, filter = {}, target = ".pagination-control") =>
    @contentPerPage = contentPerPage
    @contentCount = contentCount
    @filter = filter
    @results = {}
    @target = target
    return @buildInitialPages(contentApi, populateTable, contentPerPage) unless contentCount
    paginationHtml = if @pageNumbers(contentCount) > 0 then @buildPaginationList(@totalPages, @page) else ""
    $(@target).html paginationHtml
    @getPageContent(@contentPage, contentApi, populateTable)

  pageNumbers: (contentCount) =>
    if contentCount <= @contentPerPage
     $(@target).hide()
     @totalPages = 0
    else
      $(@target).show()
      @totalPages = Math.ceil contentCount / @contentPerPage
    return @totalPages

  addActiveClass: (value, currentPage) ->
    activePage = if currentPage == value then "active-page" else ""
    return activePage

  listPageNumber: (value, currentPage) ->
    return "<li class='page #{@addActiveClass(value, currentPage)}'>#{value}</li>"

  appendTruncation: ->
    return '<li class="grey-out truncated-section" disabled>...</li>'

  disablePrevious: (currentPage) ->
    if currentPage == 1
      return "class='prev-next grey-out prev-arrow' disabled"
    else
      return "class='prev-next prev-arrow'"

  disableNext: (currentPage) =>
    self = @
    if currentPage == self.totalPages
      return "class='prev-next grey-out next-arrow' disabled"
    else
      return "class='prev-next next-arrow'"

  buildPaginationList: (totalPages, currentPage) ->
    preparedList = "<ul><span class='main-pages' id='curriculum-pages'><li #{@disablePrevious(currentPage)}><i class='material-icons prev'>play_arrow</i></li>"

    preparedList += @listPageNumber(1, currentPage)

    i = 2
    while i < totalPages
      if totalPages <= 7
        preparedList += @listPageNumber(i, currentPage)
      else
        if currentPage < 4 and i <= 5
          preparedList += @listPageNumber(i, currentPage)
        else if currentPage < 4 and i > 5
          preparedList += @appendTruncation()
          i = totalPages
        else if currentPage > 4 and i == currentPage
          preparedList += @appendTruncation()

        else
          preparedList += @appendTruncation()

          if currentPage >= totalPages - 2
            preparedList += @listPageNumber((totalPages - 4), currentPage)
            preparedList += @listPageNumber((totalPages - 3), currentPage)
            preparedList += @listPageNumber((totalPages - 2), currentPage)
            preparedList += @listPageNumber((totalPages - 1), currentPage)

          else
            preparedList += @listPageNumber((currentPage - 1), currentPage)
            preparedList += @listPageNumber(currentPage, currentPage)

            if (parseInt(currentPage) + 1) < totalPages
              preparedList += @listPageNumber((parseInt(currentPage) + 1), currentPage)

            if (parseInt(currentPage) + 2) < totalPages
              preparedList += @appendTruncation()

          i = totalPages
      i += 1
              
    preparedList += @listPageNumber(totalPages, currentPage) 
    preparedList += "<li #{@disableNext(currentPage)}><i class='material-icons next'>play_arrow</i></li></span></ul>"
    return preparedList

  getPageContent: (contentPage, contentApi, populateTable, useMemoized) =>
    self = @
    $('li.page').on 'click', (e) ->

      if $(this).hasClass('active-page')
        return

      self.page = $(this).html()
      return self.handlePageChange(e) if useMemoized
      self.togglePage(self.page, contentApi, populateTable)

    $('li.prev-next').on 'click', (e) ->
      context = $(this)
      previous = $(this).children().hasClass('prev')
      next = $(this).children().hasClass('next')
      self.togglePrevAndNextPages(context,
          previous, next, contentApi, populateTable, useMemoized, e)
  
  togglePage: (page, contentApi, populateTable) ->
    @page = parseInt page
    paginationHtml = @buildPaginationList(@totalPages, @page)
    $('.pagination-control').html paginationHtml
    @initialize(@contentCount, contentApi, populateTable, @contentPerPage, @filter)

    @loaderUI.show()
    contentApi(@contentPerPage, @page, @filter).then(
      (responseData) =>
        @loaderUI.hide()
        @allResult = responseData.paginated_data
        populateTable(responseData.paginated_data, responseData.submissions_count)
    )
    return
  
  togglePrevAndNextPages: (context, previous, next, contentApi, populateTable, useMemoized, e) =>
    if previous and @page == 1
      context.prop('disabled', true).addClass('grey-out')

      if($(".prev-arrow").attr('disabled'))
        return
      
    else if previous and @page > 1
      @page = (Number(@page) - 1)
      paginationHtml = @buildPaginationList(@totalPages, @page)
      $('.pagination-control').html paginationHtml
      return @handlePageChange(e) if useMemoized
      @initialize(@contentCount, contentApi, populateTable, @contentPerPage, @filter)

    else if context.children().hasClass('next') and @page >= @totalPages
      context.attr('disabled', 'disabled').addClass('grey-out')

      if($(".next-arrow").attr('disabled'))
        return

    else if next and @page < @totalPages
      @page = (Number(@page) + 1)
      paginationHtml = @buildPaginationList(@totalPages, @page)
      $('.pagination-control').html paginationHtml
      return @handlePageChange(e) if useMemoized
      @initialize(@contentCount, contentApi, populateTable, @contentPerPage, @filter)

    return @handlePageChange(e) if useMemoized
    @loaderUI.show()
    contentApi(@contentPerPage, @page).then(
      (responseData) =>
        @loaderUI.hide()
        @allResult = responseData.paginated_data
        populateTable(responseData.paginated_data, responseData.submissions_count)
    )
    return
  
  resetPaginationControl: =>
    @page = 1
    @allResult = {}
    @results = {}

  modifyPageNumber: () ->
   $('.prev-next').removeClass('grey-out')
   $('.prev-next').removeAttr("disabled")
   if parseInt(@page) >= @totalPages
     $('.next-arrow').attr("disabled", true)
     $('.next-arrow').addClass('grey-out')
     @page = @totalPages
   else if parseInt(@page) <= 1
     $('.prev-arrow').attr("disabled", true)
     $('.prev-arrow').addClass('grey-out')
     @page = 1

   paginationHtml = @buildPaginationList(@totalPages, @page)
   $('.pagination-control').html paginationHtml
   @getPageContent(@contentPage, @contentApi, @populateTable, true)

  

  handleActivePage: (e) ->
    self = @
    $(".page:visible").filter( ->
        if $(this).text() == self.page.toString()
          $(this).addClass('active-page')
          $(this).siblings().removeClass('active-page')
    )

  handlePageChange: (e) ->
   @modifyPageNumber()
   @handleActivePage(e)
   page = @page.toString()
   return @populateTable(@results[page]) if @results[page]
   @loaderUI.show()
   path = @path || "paginate=true&limit=#{@contentPerPage}&offset=#{page}"
   @contentApi(path)
   .then((response) =>
      target = if @keyInResponse then @wrapper(response)[@keyInResponse] else response.paginated_data
      @results[page] = target
      @populateTable(target)
      @loaderUI.hide()
   )

  buildInitialPages: (result, count = 10,
  key, recomputeWithCount, wrapper = (data) -> (data)) =>
     @wrapper = wrapper
     @keyInResponse = key
     @results = {}
     executePagination = () =>
       paginationHtml = if @pageNumbers(count) > 0 then @buildPaginationList(@totalPages, @page) else ""
       recomputeWithCount && recomputeWithCount(count)
       $(@target).html paginationHtml
       @getPageContent(@contentPage, @contentApi, @populateTable, true)
     if result
      @page = 1
      @results[@page.toString()] = result
      executePagination()

         

