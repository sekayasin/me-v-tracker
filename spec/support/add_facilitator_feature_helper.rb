require "capybara"

def add_facilitator_helper(camper)
  find("a#add-lfa").click
  find("div#facilitator-Nigeria").click
  find(".show-second-tab").click
  page.all("span.ui-selectmenu-text")[0].click
  find("li", text: "Lagos").click
  sleep 1
  page.all("span.ui-selectmenu-text")[1].click
  find("li", text: "Week 1").click
  sleep 2
  fill_in("learner_name", with: camper[:first_name])
  find("li", text: "#{camper[:first_name]} #{camper[:last_name]}").click
  fill_in("input_fac_email", with: "test.andelan@andela.com")
  find(".post-form-request").click
  sleep 2
end
