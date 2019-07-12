require "capybara"

def upload_learner_helper(filename)
  find("div.btn-wrapper a#add-learner").click
  sleep 2
  find("div#Nigeria").click
  sleep 1
  find(".show-second-tab").click
  sleep 1
  page.all("span.ui-selectmenu-text")[0].click
  find("li", text: "Bootcamp v1").click
  page.all("span.ui-selectmenu-text")[1].click
  find("li", text: "Python/Django").click
  page.all("span.ui-selectmenu-text")[2].click
  find("li", text: "Lagos").click
  fill_in("select_start_date", with: "2018-01-31")
  find("button.ui-datepicker-close", text: "CLOSE").click
  fill_in("select_end_date", with: Date.current)
  find("button.ui-datepicker-close", text: "CLOSE").click
  fill_in("enter_cycle_number", with: "999999999")
  attach_spreadsheet_file(filename)
  sleep 1
  find(".post-form-request").click
  sleep 2
end
