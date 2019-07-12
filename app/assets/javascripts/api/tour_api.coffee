class Tour.API
  constructor: ->

  getUserTourStatus: (page) =>
    return $.ajax(
      url: "/tours/#{page}"
      type: "GET"
    )

  createTourEntry: (page) =>
    return $.ajax(
      url: "/tours/#{page}"
      type: "POST"
    )
