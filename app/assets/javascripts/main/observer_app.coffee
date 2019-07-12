class Observer.App
  setMutationObserver: (campersRecords, beforeUpgrade, afterUpgrade) =>
    observer = new MutationObserver((mutations)->
      @disconnect()
      addedElements = $(mutations[0].addedNodes)
      beforeUpgrade(addedElements)
      componentHandler.upgradeDom()
      if afterUpgrade != undefined
        afterUpgrade()
      return
    )
    config = { childList: true }
    observer.observe(campersRecords, config)
