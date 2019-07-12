def profile_spec_helper
  stub_andelan
  stub_current_session
  select_camper
end

def select_camper
  visit("/")
  find("a.dropdown-input").click
  find("ul#index-dropdown li a.dropdown-link",
       text: @first_program.name).click

  find("img.proceed-btn").click
  click_on "Learners"
  camper_name = @bootcamper.first_name + " " + @bootcamper.last_name
  click_link(camper_name)
  sleep 1
end
