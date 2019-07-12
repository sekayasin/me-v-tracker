class RestoreFacilitatorModel < ActiveRecord::Migration[5.0]
  def change
    create_table :facilitators do |t|
      t.string   :first_name, :null => false
      t.string   :last_name,  :null => false 
      t.string   :email,      :null => false
      t.string   :city
      t.string   :country
      t.timestamps
    end
  end
end
