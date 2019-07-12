class AllPrograms.UI
  constructor: (programAPI)->
    @singleProgramModal = new Modal.App('#single-program-modal', 760, 700, 400, 400)
    @emptyState = new EmptyState.UI()
    @pagination = new PaginationControl.UI()
    @sortApp  = new Sorting.App()
    @allPrograms = {}
    @page = 1
    @contentPerPage = 10
    @allProgramsCount = 0
    @programAPI = programAPI

  openAllPrograms: (getAllPrograms) =>
    $('#all-programs').css('display', 'block')
    $('#all-programs-body').html('')
    $(".all-programs").css("overflow", "hidden")
    @initializeAllPrograms(getAllPrograms)
    @sortIconListener(@getSortedPrograms)
  
  initializeAllPrograms: (getAllPrograms) ->
    self = @
    return unless pageUrl[1] == 'programs'
    getAllPrograms(self.contentPerPage, self.page).then(
      (programsData) ->
        self.allPrograms = programsData.paginated_data
        self.allProgramsCount = programsData.programs_count
        self.populateAllProgramsTable(programsData.paginated_data)
        self.pagination.initialize(
          self.allProgramsCount, getAllPrograms,
          self.populateAllProgramsTable, self.contentPerPage
        )
      (error) ->
        $('.all-programs-body-wrapper').addClass('display', 'none')
        $('.program-content').html self.emptyState.getNoContentText()
    )

  programDetails: () =>
    return unless pageUrl.length == 3 and pageUrl[2]
    @programAPI.fetch(pageUrl[2]).then((data) => 
       $('#single-title').html(data.name)
    )
    programDetailsUI = new ProgramDetails.UI(pageUrl[2])
    programDetailsApi = new ProgramDetails.API()
    programDetailsUI.fetchProgramDetails(
        programDetailsApi.getProgramDetails
    )

  initializeSingleProgramModal: (allPrograms) =>
    self = @
    $.each(allPrograms, (index, program) ->
      if program.save_status
        $("#view-icon-#{program.id}, ##{program.id}").off('click').on 'click', =>
          $('#single-program-modal-title').html(program.name)
          self.singleProgramModal.open()
          programDetailsUI = new ProgramDetails.UI(program.id)
          programDetailsApi = new ProgramDetails.API()
          programDetailsUI.fetchProgramDetails(
            programDetailsApi.getProgramDetails
          )
    )
    $('.single-program-close-button').on 'click', =>
      self.singleProgramModal.close()
  window.onscroll = ->
    if $(window).scrollTop() >= 110
      $('.all-programs-table_fixed').addClass('fixed-top')
    else
      $('.all-programs-table_fixed').removeClass('fixed-top')
  populateAllProgramsTable: (programsList)=>
    self = @
    if programsList? && programsList.length is 0
      $('.all-programs-body-wrapper').addClass('display', 'none')
      $('.programs-content').html self.emptyState.getNoContentText()
    else
      retrievedPrograms = programsList
      programRows = ''

      $.each(retrievedPrograms, (index, retrievedProgram) ->
        programRows += self.buildProgramRow(index, retrievedProgram) 
      )

      $('#all-programs-body').html programRows
      self.initializeSingleProgramModal(programsList)


  buildProgramRow: (index, program) ->
    self = @
    "<tr class='programs-row-wrapper'>
      <td class='name-data'>
        <i class='material-icons #{if program.save_status then 'finalised' else 'not-finalised' }'>
          #{if program.save_status then 'lock' else 'lock_open'}
        </i>
        <a id='#{program.id}'
           class='program-url'
           href=#{if program.save_status then '#' else "/programs/#{program.id}/edit"}>
          #{program.name}
        </a>
      </td>
      <td class='description-data'>
        <span>
          #{if program.description == null  || program.description == ""
              "N/A"
            else
              program.description
          }
        </span>
        
        
      </td>
      <td class='stack-data'>
        #{if program.language_stacks.length == 0
            '<span>No Languages/Stacks Added</span>'
          else
            "<ul class='stack-list'>
              #{self.listBuilder(program.language_stacks, 'stack')}
            </ul>"
        }
      </td>
      <td class='phase-data'>
        #{if program.phases.length == 0
            "<span class='empty-column'>No Phase Added</span>"
          else
            "<ol class='phase-list'>
              #{self.listBuilder(program.phases, 'phase')}
            </ol>"
        }
      </td>
      <td class='duration-data'>
        #{if program.estimated_duration == 0 || program.estimated_duration == ''
            "<span>No Duration Set</span>"
          else
            "<span>
              #{self.buildProgramDuration(program.estimated_duration)}
            </span>"
        }
      </td>
      <td class='action-data'>
        #{self.renderEditIcon(program)}
        <span class='remove-icon#{if program.save_status then '-disabled' else ''}'></span>
        <span
          id='view-icon-#{program.id}'
          class='view-icon#{if program.save_status then '' else '-disabled'}'>
        </span>
      </td>
    </tr>"

  generateProgramEditURL: (program) ->
    if program.id
      "/programs/" + program.id + "/edit"
    else
      ""

  renderEditIcon: (program) ->
    self = @
    if program.save_status
      '<span class="edit-icon-disabled"></span>'
    else
      "<a href=#{self.generateProgramEditURL(program)}>" +
      '<span class="edit-icon"></span></a>'

  listBuilder: (listings, type) ->
    preparedList = ''

    $.each(listings, (index, listing) ->
      if type == 'stack'
        preparedList += "<li>- #{listing.name}</li>"
      else
        preparedList += "<li>#{index+1}. #{listing.name} </li>"
    )

    return preparedList
  
  buildProgramDuration: (days) ->
    displayText = if days > 1 then "#{days} days" else "#{days} day"
    
    if displayText == '0 day'then 'No Duration Set' else displayText
  
  sortOrderIcon: (orderBy, elementClicked) ->
    if orderBy == -1
      elementClicked.removeClass("sort-icon-asc-outcomes").addClass("sort-icon-desc-outcomes")
    else
      elementClicked.removeClass("sort-icon-desc-outcomes").addClass("sort-icon-asc-outcomes")

  prepareSortablePrograms: (programs) =>
    sortablePrograms = programs
    sortablePrograms.map (program) -> program['name'] = program.name
    return sortablePrograms
  
  getSortedPrograms: (allPrograms, orderBy, sortField, sortApp) =>
    self = @
    return self.sortApp.sort(
      self.prepareSortablePrograms(allPrograms),
      orderBy,
      sortField
    )
  
  sortIconListener: (getSortedPrograms) ->
    self = @
    $(".sort-icon-outcomes").on "click", (event) ->
      event.stopImmediatePropagation()
      orderBy = if $(this).css("background-image").includes("a-z") then -1 else 1
      self.sortOrderIcon(orderBy, $(this))
      sortField = ''

      if $(this).hasClass('name')
        sortField = 'name'
      else
        sortField = 'estimated_duration'

      allPrograms = if self.pagination.allResult.length > 0 then self.pagination.allResult else self.allPrograms
      retrievedPrograms = self.getSortedPrograms(allPrograms, orderBy, sortField, self.sortApp)
      self.populateAllProgramsTable(retrievedPrograms)
  
  goToProgram: ->
    $('.program-url').on 'click', ->
      self = this
      programId = $(self).attr('id')
      localStorage.setItem('programId', programId)

