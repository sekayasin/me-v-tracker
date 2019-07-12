# Behaviours and hooks for the updating and getting decision reasons
$(document).ready =>
  if (pageUrl[1] == 'curriculum')
    criteria = new Criteria.App()
    criteria.start()

