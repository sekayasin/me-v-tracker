$(document).ready ->
  $('#num_rows').change ->
    vof.displayLimitSpinner()
    selectedLimit = $(this).val()
    url = ""
    splitUrl = window.location.search.substr(1).split('&')

    # Checks if the url has search parameters
    if splitUrl.length == 1
      url = '?size=' + selectedLimit
    else
      foundLimit = false

      # Checks if search parameters has size and page parameters
      splitUrl.forEach (element, index) ->
        if element.split('=')[0] == 'size'
          splitUrl[index] = 'size=' + selectedLimit
          foundLimit = true
        else if element.split('=')[0] == 'page'
          splitUrl[index] = 'page=1'

      url = "?" + splitUrl.join('&')

      unless foundLimit
        url = url + '&size=' + selectedLimit

    # Checks if save filter data option is checked
    if ($('.filled-in:checkbox').is(':checked'))
      localStorage.setItem 'url', window.location.origin + '/' + url

    # Make ajax call to return records
    $.ajax
      type: 'GET'
      url: '/'
      contentType: 'application/json;charset=utf-8'
      dataType: 'json'
      data: { size : selectedLimit }
      success: (response) ->
        $.ajax({
          method: "GET",
          url: url,
          dataType: "script"
        })
    return
