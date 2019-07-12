module LearnerPageHelper
  def toggle_lfa_columns
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link").click
    find("img.proceed-btn").click
    click_on "Learners"
    find("th.filter").click
    find("ul.colum-filter-list > li:nth-child(14)").click
    find("ul.colum-filter-list > li:nth-child(15)").click
  end
end
