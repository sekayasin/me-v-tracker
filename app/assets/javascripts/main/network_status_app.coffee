class NetworkStatus.App
  constructor: ->
    @networkStatusUi = new NetworkStatus.UI()

  start: =>
    @networkStatusUi.initializeNetworkStatus()
