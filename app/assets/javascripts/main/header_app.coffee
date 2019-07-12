class Header.App
  constructor: ->
    paths = [
      '/login',
      '/',
      '/learner',
      '/learner/ecosystem',
      '/surveys-v2',
      '/surveys',
      "/surveys-v2/responses/#{pageUrl[3]}",
      "/surveys-v2/respond/#{pageUrl[3]}",
      "/surveys-v2/#{pageUrl[2]}/edit",
      "/support"
    ]
    programId = localStorage.getItem("programId")
    if !programId
       url_string = window.location.href
       url = new URL(url_string)
       programId = url.searchParams.get("programId")
       if programId and programId != null
         localStorage.setItem('programId', programId)
         window.location.reload()
    if !localStorage.getItem("programId") and location.pathname not in paths
      window.location = "/learners"

    @ui = new Header.UI()
    @api = new Header.API(localStorage.getItem('programId'))
