class LearnersTable.UI
  constructor: ->
    @selectBox = document.getElementsByClassName('select-box')
    @filterOption = JSON.parse(localStorage.getItem('filterOptions')) or {
      program_id: 'All'
      city: 'All'
      cycle: 'All'
      decision_one: 'All'
      decision_two: 'All'
      week_one_lfa: 'All'
      week_two_lfa: 'All'
      user_action: 'f'
    }
    @filterMeta = {}
    @decisionOneSelections = $('.decision-one .decision-status-input')
    @decisionTwoSelections = $('.decision-two .decision-status-input')

  initializeFiltering: (initializeTableUpdater, initializeFilters, fetchFilterData) =>
    @fetchFilterData = fetchFilterData
    @handleFilterParamsChange(initializeTableUpdater)
    @handleDropdownToggle()
    @handleDropdownClose()
    if localStorage.getItem('filterOptions') and  !window.location.search.split('&')[1]
      if JSON.parse(localStorage.getItem('filterOptions')).program_id == localStorage.getItem('programId')
        initializeFilters

  # generate each checkboxes in a single dropdown
  generateOptionDropdown: (options) =>
    # default "All" checkbox

    self = @
    # make API call to get the checkboxes
    self.fetchFilterData(self.buildFilterParams()).then((result) ->
      self.dropdownVariables = result
      self.filterMeta = result
      initialOptions = options

      self.populateDropdown(result, options, initialOptions)

    )

  populateDropdown: (results, options, initialOptions) ->
    self = @
    list =  """
              <li class='checkbox-list' data-value='All'>
                <label class='mdl-checkbox mdl-js-checkbox' for='all'>
                  <input type="checkbox" id='all' class='mdl-checkbox__input mdl-checkbox__input-mts filter-item' data-value='all' data-parent='#{options}' disabled checked/>
                  <span> All </span>
                </label>
              </li>
            """
    # check if particular checkbox is any of the lfas and then change the key
    options = 'lfas1' if options == 'lfas-1'
    options = 'lfas2' if options == 'lfas-2'
    if Object.entries(@filterMeta) && @filterMeta[options]
      for option, index in @filterMeta[options]
        # if we are about to generate an lfa options dropdown
        if option.email
          # use the name from the email.
          option = option.email
          list += """
                    <li class='checkbox-list' data-value='#{option}'>
                      <label class='mdl-checkbox mdl-js-checkbox'  for='#{option}_#{initialOptions}_#{index + 1}'>
                        <input type="checkbox" id='#{option}_#{initialOptions}_#{index + 1}' class='mdl-checkbox__input mdl-checkbox__input-mts filter-item' data-value='#{option}' data-parent='#{initialOptions}'/>
                        <span class='mdl-checkbox__label lfa-filter-item'> #{self.getLfaName(option)} </span>
                      </label>
                    </li>
                  """
        else
          # or we are about to generate a regular dropdown
          list += """
                    <li class='checkbox-list' data-value='#{option}'>
                      <label class='mdl-checkbox mdl-js-checkbox'  for='#{option}_#{initialOptions}_#{index + 1}'>
                        <input type="checkbox" id='#{option}_#{initialOptions}_#{index + 1}' class='mdl-checkbox__input mdl-checkbox__input-mts filter-item' data-value='#{option}' data-parent='#{initialOptions}'/>
                        <span class='mdl-checkbox__label'> #{option} </span>
                      </label>
                    </li>
                """
    options = initialOptions
    # populate the dropdown
    $("##{options}-dropdown").html list

    $("#locations-dropdown li label input[type=checkbox]").on 'click', ->
      # if the options is cycles, update the text in the cycle label. Do same for lfa-1, lfa-2 etc.
      if options == 'cycles'
        # reset the cycle and LFA lists back to All (the default with nothing selected.)
        self.filterOption.cycle = 'All'
        self.filterOption.week_one_lfa = 'All'
        self.filterOption.week_two_lfa = 'All'
        self.filterOption.decision_one = 'All'
        self.filterOption.decision_two = 'All'
        # reset the cycle and LFA label text back to All (the default with nothing selected.)
        $('#label-cycle').text('All')
        $('#label-week_two_lfa').text('All')
        $('#label-week_one_lfa').text('All')
        # resets decision dropdown
        self.resetDecisionDropdown()
        # remove the lfa options
        $('#lfas-1-dropdown li:not(:first)').remove()
        $('#lfas-2-dropdown li:not(:first)').remove()

      if options == 'lfas-1' || options == 'lfas-2'
        self.filterOption.week_one_lfa = 'All'
        self.filterOption.week_two_lfa = 'All'
        self.filterOption.decision_one = 'All'
        self.filterOption.decision_two = 'All'
        # reset the cycle and LFA label text back to All (the default with nothing selected.)
        $('#label-week_two_lfa').text('All')
        $('#label-week_one_lfa').text('All')
        self.resetDecisionDropdown()

    # initialize the checkboxes using mdl because they were just inserted into the DOM
    self.initializeCheckbox(options)

    # initialize the event handler for when a checkbox is clicked
    self.handleFilterParamsChange()

  initializeCheckbox: (options) =>
    $(".#{options}-dropdown .mdl-js-checkbox").each ->
      new window.MaterialCheckbox(@)

  # resets decision dropdown
  resetDecisionDropdown: =>
    $('#label-decision_one').text('All')
    $('#label-decision_two').text('All')
    $("input[id^='decision_one']:enabled").removeAttr('checked')
    $("input[id^='decision_two']:enabled").removeAttr('checked')
    $("label[for^='decision_one']").slice(1).removeClass('is-checked')
    $("label[for^='decision_two']").slice(1).removeClass('is-checked')

  # event fired when the options dropdown is clicked
  handleDropdownToggle: =>
    self = @
    $(@selectBox).on 'click', (event) ->
      # false because we only want to close one particular dropdown
      self.closeDropdown(false)

      # save the current closed value
      thisClosedValue = $(@).attr('closed')
      # set it to closed
      $(self.selectBox).attr('closed', 'true')
      # set it back to initial value
      $(@).attr('closed', thisClosedValue)

      # if it's close or has not been closed before (still closed)
      if ($(@).attr('closed') == 'true' || $(@).attr('closed') == undefined)
        # change closed value, update icon direction and hide option dropdown
        $(@).attr('closed', 'false')
        $(@).addClass('arrow-up-icon')
        $(@).removeClass('arrow-down-icon')
        $(@).next('.list-wrapper').removeClass('hidden')
      else
        $(@).attr('closed', 'true')
        $(@).addClass('arrow-down-icon')
        $(@).removeClass('arrow-up-icon')
        $(@).next('.list-wrapper').addClass('hidden')

  # initialize event listener for when any place is clicked and the option drodpowns needs to be closed
  handleDropdownClose: =>
    self = @
    # when it's the body that was clicked
    $('body').on 'click', (event) ->
      # close all option dropdowns
      self.closeDropdown()

    # when within the "big, enclosing dropdown" was clicked
    $('.mdl-menu.mdl-js-menu.parent-dropdown').on 'click', (event) ->
      # and the element that was clicked is not the toggle for the option dropdown itself
      if ($(event.target).attr('class').split(" ")[0] != 'select-box')
        self.closeDropdown()

  closeDropdown: (all = true) =>
    $('.list-wrapper').addClass('hidden')
    $('.list-wrapper > .mdl-menu__container').removeClass('is-visible')
    $('.list-wrapper > .mdl-menu__container').css({'width': '0', 'height': '0'})
    $('.list-wrapper > .mdl-menu__container > .mdl-menu__outline').css({'width': '0', 'height': '0'})
    $(@selectBox).removeClass('arrow-up-icon')
    $(@selectBox).addClass('arrow-down-icon')

    # if we are about to close all the option dropdowns
    if (all)
      $(@selectBox).attr('closed', 'true')

  handleFilterParamsChange: (initializeTableUpdater) =>
    self = @
    # set the program id
    @setProgramID()
    $('.checkbox-list > .mdl-checkbox.mdl-js-checkbox').off 'click'
    ## Clicking on some points like paddings and margins still close the modal
    ## So we prevent that behaviour
    $('.mdl-menu.mdl-js-menu.parent-dropdown').on 'click', (event) ->
      if $(event.target).attr('type') != 'checkbox'
        event.stopPropagation()

    $(".checkbox-list > .mdl-checkbox.mdl-js-checkbox"). on 'click', (event) ->
      event.stopPropagation()
      if $(event.target).attr('type') != 'checkbox' && $(this).parent().attr('data-value') != 'All'
        parent = $(this).parent().parent()
        filterValue = $(this).parent(). attr 'data-value'

        # update filterOption based on what options were selected
        # varies for single and multiple selection
        if self.filterOption[parent.attr('data-key')] == 'All'
          # if it's "All", simply set to an empty array
          self.filterOption[parent.attr('data-key')] = []
        else
          # change the current value to an array and put back in filterOption
          self.filterOption[parent.attr('data-key')] = self.filterOption[parent.attr('data-key')].split(',')

        # if we've not selected it before then just push to the array else remove
        index = self.filterOption[parent.attr('data-key')].indexOf(filterValue)
        if index == -1
          self.filterOption[parent. attr('data-key')].push(filterValue)
        else
          self.filterOption[parent. attr('data-key')].splice(index, 1)

        # Finally, if the value in the filterOption key not empty,
        # convert everything to a string and put back
        if self.filterOption[parent. attr('data-key')].length != 0
          self.filterOption[parent. attr('data-key')] = self.filterOption[parent. attr('data-key')].join(',')
        else
          # if it's empty, set to "All"
          self.filterOption[parent. attr('data-key')] = 'All'

        # Define the label display text during filtering
        label = parent. attr('data-key')
        selectedValues = self.filterOption[label].split(',')
        optionsCount = parent.children().length - 1
         # labelText is the comma delimited value in the options select element
        labelText = selectedValues.length + ' of ' + optionsCount + ' selected'
        if (selectedValues.length == optionsCount)
          labelText = 'All Selected'
        # if we are currently looking at lfas, we only need their names
        else if ((label == 'week_one_lfa' || label == 'week_two_lfa') &&
        self.filterOption[label] != 'All') && (selectedValues.length <= 1)
          labelText = selectedValues.map((lfa) -> self.getLfaName(lfa)).join('')
        else if (label != 'week_one_lfa' && label != 'week_two_lfa' && selectedValues.length <= 2)
          labelText = selectedValues.join(', ')

        # Reset some filters when city is set to "All"
        if labelText == 'All' && label == 'city'
          $('#label-cycle').text("All")
          self.filterOption = {
            program_id: self.filterOption.program_id
            city: 'All'
            cycle: 'All'
            decision_one: self.filterOption.decision_one
            decision_two: self.filterOption.decision_two
            week_one_lfa: 'All'
            week_two_lfa: 'All'
            user_action: 'f'
          }

        # Reset some other filters when cycle or city is set to "All"
        if (labelText == 'All' && label == 'cycle') || (labelText == 'All' && label == 'city')
          $('#label-week_one_lfa').text("All")
          $('#label-week_two_lfa').text("All")
          self.filterOption = {
            program_id: self.filterOption.program_id
            city: self.filterOption.city
            cycle: 'All'
            decision_one: self.filterOption.decision_one
            decision_two: self.filterOption.decision_two
            week_one_lfa: 'All'
            week_two_lfa: 'All'
            user_action: 'f'
          }
          # generate (empty) the lfa filters
          self.generateOptionDropdown 'lfas-1'
          self.generateOptionDropdown 'lfas-2'

        $("#label-#{label}").text(labelText)
        if parent.attr('data-next') != undefined
          self.generateOptionDropdown(parent.attr('data-next'))

          if parent.attr('data-next') == 'lfas-1'
            self.generateOptionDropdown 'lfas-2'

        # initialize the apply button click listener
        initializeTableUpdater

  setProgramID: =>
    @filterOption['program_id'] = localStorage.getItem('programId')

  getLfaName: (lfa) =>
    lfaName = lfa.split('@')[0]
    return lfaName.split(".").join(" ")

  moveScrollBar: (position) =>
    $('.pane-vScroll').scrollTop(position)

  removeFilteringLoader: =>
    $('.loader-modal').hide()

  clearCurrentRecords: =>
    $('.campers-table-body > tr').remove()

  createParentAlias: (parent) =>
    if (parent == 'decision_one')
      parent_alias = 'decision1'
    else if (parent == 'decision_two')
      parent_alias = 'decision2'
    else if (parent == 'week_one_lfa')
      parent_alias = 'lfa1'
    else if (parent == 'week_two_lfa')
      parent_alias = 'lfa2'
    else
      parent_alias = parent
    return parent_alias

  prepareTable: =>
    $('.loader-modal').show()
    $('.all-campers-no-data').addClass('hidden')
    # hide all the rows on the table at the start
    $('.campers-table-body > tr').addClass('hidden')

  # update the count of how many filter options where used
  updateFilterCount: =>
    filterCount = 0
    self = @
    Object.keys(self.filterOption).map((objectKey, index) ->
      value = self.filterOption[objectKey];
      if value != 'All'
        filterCount += 1
    );
    # Minus 2 because the object has two keys that do not translate to filters:
    # program_id and user_action
    $('.filter-btn .mdl-badge').attr('data-badge', filterCount - 2)
    if filterCount - 2 != 0
      $('.filter-btn .mdl-badge').show().css('display', 'inline-block')
    else
      $('.filter-btn .mdl-badge').hide()

    @updateFilterStatusText(filterCount - 2)

  # changes based on if we filtered anything at all or not
  updateFilterStatusText: (count) =>
    if count == 0
      $('.learners-type').text('All Learners')
      $(".clear-filters-btn").addClass("hide")
    else
      $(".clear-filters-btn").removeClass("hide")
      $(".export-btn").css({"margin-left": "5px"})
      $('.learners-type').text('Filtered Learners')

  # This method can be called outside of this class in order to re-filter the table incase the DOM is updated
  refilterLearnersTable: () =>
    $('.btns.apply-btn').trigger('click')

  # changes filterOption to a string in order to make a server request
  # for getting next filter options
  buildFilterParams: =>
    self = @
    baseUrl = window.location.protocol + '//' + window.location.host + '/learners?'

    Object.keys(self.filterOption).forEach (parent) ->
      baseUrl += parent + '=' + self.filterOption[parent] + '&'
      return
    return baseUrl.substr(0, baseUrl.length - 1)

  getFilterParams: =>
    return @buildFilterParams()

  getLearnerId: (element) =>
    return element.id.split("-")[4...].join("-")

  setTableDecisionState: (decisionOneSelections, decisionTwoSelections) =>
    self = @
    $.each(decisionOneSelections, (index, decisionOneSelection) ->
      decision1Value = decisionOneSelection.value
      camperDataId = self.getLearnerId(decisionOneSelection)
      if decision1Value
        decisionTwoSelection = decisionTwoSelections.filter((index) ->
          return $(this).attr('id') == "decision-status-two--#{camperDataId}"
        )[0]
        if $(decisionOneSelection).attr('disabled') == 'disabled' || decision1Value.trim() !in ['Advanced', 'Fast-tracked']
          $(decisionTwoSelection).attr('disabled','disabled')
        else
          $(decisionTwoSelection).removeAttr('disabled')
          return
    )

  updateDecisionsDropdownState: ->
    self = @
    self.decisionOneSelections = $('#campers-table-records .decision-one .decision-status-input')
    self.decisionTwoSelections = $('#campers-table-records .decision-two .decision-status-input')
    self.setTableDecisionState(self.decisionOneSelections, self.decisionTwoSelections)

  setLfaDropdownState: =>
    self = @
    $.each($('.decision-one .decision-status-input'), (index, element) ->
      if element.value !in ['Advanced', 'Fast-tracked']
        learnerId = self.getLearnerId(element)
        $("#lfa-week-2--#{learnerId}").attr('disabled', 'disabled')
    )

  handleLfaUpdate: (apiUpdateLearnerLfa) =>
    self = @
    $(document).on 'click', '.lfa-1-item, .lfa-2-item', () ->
      lfa = $(this).attr('data-value')
      if $(this).attr('data-lfa') == 'lfa-1'
        week = week_one_lfa: lfa
      else
        week = week_two_lfa: lfa

      displayInput = $(this).parent().parent().parent().find('.mdl-textfield__input')

      displayInput.val($(this).text().trim())

      learner = $(this).parentsUntil('tbody').find('.learner-name')

      lfaList = [{
        lfa,
        learner: learner.text().trim(),
        camper_id: learner[0].pathname.split("/")[2],
        learner_program_id: learner[0].pathname.split("/")[3]
      }]

      apiUpdateLearnerLfa(week, $(this).attr('data-id')).then( ->
        self.showLfaUpdateMessage(true)
        Notifications.App.sendLfaNewLearnerNotification(lfaList)
      ).catch( -> self.showLfaUpdateMessage(false))

  showLfaUpdateMessage: (isSuccess) =>
    if isSuccess
      $('.toast').messageToast.start('Learner\'s LFA was updated successfully', 'success')
    else
      $('.toast').messageToast.start('An error occurred while updating Learner\'s LFA', 'error')

  saveFilters: ->
    unless localStorage.getItem('defaultOptions')
      localStorage.setItem('defaultOptions', JSON.stringify(@filterOption))
      return
    if @dropdownVariables && Object.entries(@dropdownVariables).length
      localStorage.setItem('dropdownVariables', JSON.stringify(@dropdownVariables))
    if @filterOption && @filterOption != JSON.parse(localStorage.getItem('defaultOptions'))
      localStorage.setItem('filterOptions', JSON.stringify(@filterOption))

  populateCheckboxes: =>
    self = @
    dropdownVariables = JSON.parse(localStorage.getItem('dropdownVariables') or JSON.stringify({}))
    @dropdownVariables = dropdownVariables
    @filterMeta = dropdownVariables

    currentFilters = @filterOption
    cities = currentFilters.city.split(',')
    cycles = currentFilters.cycle.split(',')
    lfasOne = currentFilters.week_one_lfa.split(',')
    lfasTwo = currentFilters.week_two_lfa.split(',')
    descisionsOne = currentFilters.decision_one.split(',')
    descisionsTwo = currentFilters.decision_two.split(',')

    checkboxAction = (values, label, labelValue, target)->
      $(label).text(labelValue)

      for value in values
        switch
          when target == 'first'
            $("li[data-value*='"+ value + "'] >.mdl-checkbox.mdl-js-checkbox > .mdl-checkbox__input").first().click()

          when target == 'last'
            $("li[data-value*='"+ value + "'] >.mdl-checkbox.mdl-js-checkbox > .mdl-checkbox__input").last().click()

          when target == 'city'
            $("li[data-value*='"+ value + "'] >.mdl-checkbox.mdl-js-checkbox > .mdl-checkbox__input").click()
            options = "cycles"
            initialOptions = options
            self.populateDropdown(dropdownVariables, options, initialOptions)

          when target == 'cycle'
            $("li[data-value*='"+ value + "'] >.mdl-checkbox.mdl-js-checkbox > .mdl-checkbox__input").click()
            options = "lfas-1"
            initialOptions = options
            self.populateDropdown(dropdownVariables, options, initialOptions)

            options = "lfas-2"
            initialOptions = options
            self.populateDropdown(dropdownVariables, options, initialOptions)

    lfaNames = (lfas) ->
      lfaByName = ''
      for lfa in lfas
        lfaByName += lfaByName + self.getLfaName(lfa) + ','
      return lfaByName.slice(0, -1)

    checkboxAction(cities, '#label-city', currentFilters.city, 'city')
    checkboxAction(cycles, '#label-cycle', currentFilters.cycle, 'cycle')
    checkboxAction(lfasOne, '#label-week_one_lfa', lfaNames(lfasOne), 'first')
    checkboxAction(lfasTwo, '#label-week_two_lfa', lfaNames(lfasTwo), 'last')
    checkboxAction(descisionsOne, '#label-decision_one', currentFilters.decision_one, 'first')
    checkboxAction(descisionsTwo, '#label-decision_two', currentFilters.decision_two, 'last')

    return

  clearFilters:() ->
    $('a.clear-filters-btn').on 'click', (event) ->
      event.preventDefault()
      localStorage.removeItem('filterOptions')
      localStorage.removeItem('dropdownVariables')
      $(".clear-filters-btn").addClass("hide")
      $(".export-btn").css({"margin-left": "20px"})
      location.reload()
