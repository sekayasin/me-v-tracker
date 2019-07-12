class CapitalizeCity < ActiveRecord::Migration[5.0]
  def change
    Bootcamper.all.each do |camper|
      camper.update_attributes :city => camper.city.capitalize
    end
  end
end
