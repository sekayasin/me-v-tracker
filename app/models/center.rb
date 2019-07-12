require "fancy_id"

class Center < ApplicationRecord
  self.primary_key = :center_id

  validates :name, presence: true

  has_many :cycles_centers,
           dependent: :destroy,
           primary_key: :center_id,
           foreign_key: :center_id,
           class_name: "CycleCenter"

  def self.get_all_countries
    pluck(:country).uniq
  end

  before_save do
    if center_id.nil?
      self.center_id = generate_id
    end
  end

  def self.get_country(city)
    Center.find_by_name(city)[:country]
  end
end
