class CapitalizeNames < ActiveRecord::Migration[5.0]
  def change
    Bootcamper.all.each do |camper|
      camper.update_attributes :first_name => camper.first_name.capitalize
      camper.update_attributes :last_name => camper.last_name.capitalize
    end
  end
end
