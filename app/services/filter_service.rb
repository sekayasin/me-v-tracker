module FilterService
  extend self

  def build_filter_terms(values = "")
    unless values.nil?
      if values.include? ","
        values = values.split(",")
      elsif values == "null"
        values = "All"
      end
    end

    values || "All"
  end
end
