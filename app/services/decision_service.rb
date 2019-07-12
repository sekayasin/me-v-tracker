require "json"

class DecisionService
  def initialize
    @decision_data = read_file("decision_data.json")
  end

  def get_decision_data
    @decision_data
  end

  private

  def read_file(file_name)
    base_path = Rails.root.join("config", "json_data")
    file = File.read(base_path.join(file_name).to_s)
    JSON.parse file
  end
end
