require "image_processing/mini_magick"
require "telephone_number"

module LearnersProfileConcern
  extend ActiveSupport::Concern

  private

  def resolve_to_space(value)
    value.nil? ? "" : value
  end

  def exact_value(value)
    return nil unless
      value.is_a?(String) &&
      value.strip != "" &&
      value.strip != "-"

    value.strip
  end

  def extract_link_host(link)
    if link.is_a?(String)
      splited_link = link.split("/")
      splited_link.pop
      splited_link.join("/")
    end
  end

  def link_hosts
    {
      github: ["https://github.com"],
      linkedin: [
        "https://www.linkedin.com/in",
        "https://linkedin.com/in",
        "linkedin.com/in"
      ]
    }
  end

  def image_to_thumbnail_buffer(image_file)
    begin
      tmp_image = ImageProcessing::MiniMagick.
                  source(image_file).
                  resize_to_fill(300, 300).
                  convert("jpg").
                  call
    rescue ImageProcessing::Error
      tmp_image = nil
    end
    return nil unless tmp_image

    thumbnail = File.open(tmp_image, "r")
    thumbnail_buffer = thumbnail.read
    thumbnail.close
    thumbnail_buffer
  end

  def country_code(country)
    country = exact_value(country)
    return nil if country.nil?

    codes = {
      nigeria: "NG",
      kenya: "KE",
      uganda: "UG"
    }
    codes[country.downcase.to_sym]
  end

  def validate_phone_number(phone_number, country)
    iso_code = country_code(country)
    phone_number = exact_value(phone_number)
    return true if phone_number.nil?

    match = /\A\+?[0-9]*\z/.match(phone_number)
    if !iso_code.nil? && !match.nil?
      TelephoneNumber.parse(phone_number, iso_code).valid?
    else
      false
    end
  end

  def check_and_get_extension(filename, allowed_extensions = [])
    if filename.is_a?(String) && allowed_extensions.is_a?(Array)
      extension = File.extname(filename).downcase
      if allowed_extensions.include? extension
        return extension
      end
    end
    nil
  end
end
