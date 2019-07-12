$(document).ready =>
  if window.location.pathname == '/login'
    slider = new Slider.App()
    slider.start()

    login = new Login.App()
    login.start()
