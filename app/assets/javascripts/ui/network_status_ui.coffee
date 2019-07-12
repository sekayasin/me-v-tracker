class NetworkStatus.UI
  initializeNetworkStatus: =>
    window.addEventListener 'load', ->
      status = ''
    
      updateOnlineStatus = (event) ->
        if !navigator.onLine
          $('body').append('<div>'+
            '<div id="network-status"></div>'+
            '</div>');
          status = document.getElementById('network-status')

          condition = 'Your computer seems to be offline try reconnecting to continue'
          status.className = 'offline'
          status.innerHTML = condition
        else
          $(status).html('').removeClass('offline')
        
      
      window.addEventListener 'offline', updateOnlineStatus
      window.addEventListener 'online', updateOnlineStatus
