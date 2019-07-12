module SearchHelpers
  def initialize_search(modifier, search_term)
    find(".search-box").click
    find(modifier).click
    fill_in("search", with: search_term)
    find(".search-box > input").native.send_keys(:return)
  end
end
