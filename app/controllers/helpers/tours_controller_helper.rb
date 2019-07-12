module ToursControllerHelper
  def get_tourist_role
    return "Admin" if session[:current_user_info][:admin]
    return "LFA" if session[:current_user_info][:lfa]

    session[:current_user_info][:andelan] ? "Non-LFA" : "Learner"
  end

  def get_tour(page)
    Tour.find_or_create_by!(name: page)
  end

  def get_tourist(email)
    Tourist.find_or_create_by!(tourist_email: email)
  rescue ActiveRecord::RecordNotUnique
  end

  def get_content(page, role)
    base_path = Rails.root.join("lib", "assets", "tour_content")
    content = JSON.parse(File.read(base_path.join("#{page}.json").to_s))
    content.transform_values do |steps|
      steps.select do |step|
        step["role"] ? step["role"].split(", ").include?(role) : true
      end
    end
  end
end
