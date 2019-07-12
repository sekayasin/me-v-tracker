class Header.API
  constructor: (id) ->
    @getProgramDetail(id)

  getProgramDetail: (id) ->
    if location.pathname != "/" and id
      request = $.ajax(
        url: '/programs/' + id,
        type: 'GET'
      )
