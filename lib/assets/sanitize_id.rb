def sanitize_id(value)
  value&.gsub(/[^0-9]/, "")
end
