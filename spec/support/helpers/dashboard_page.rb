require "capybara"

def chart_panel(tab, contents)
  find(tab).click
  contents.each do |content|
    expect(page).to have_content(content)
  end
end
