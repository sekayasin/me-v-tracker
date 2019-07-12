class Profile.App
  constructor: ->
    @ui = new Profile.UI()

  start: ->
    @ui.hideSocialLinks()
    @ui.toggleHistoryModal()
    @ui.footerScrollAdjust()
    @ui.renderOnlyActivePhase()
