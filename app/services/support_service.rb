require "json"

class SupportService
  def initialize
    @support_data = read_file("support_data.json")
  end

  def get_support_data
    @support_data
  end

  private

  def read_file(file_name)
    base_path = Rails.root.join("config", "json_data")
    file = File.read(base_path.join(file_name).to_s)
    JSON.parse file
  end
end
