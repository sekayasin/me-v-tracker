class AddMiddlenameAndAvatarColumns < ActiveRecord::Migration[5.0]
  def change
    unless column_exists? :bootcampers, :middle_name
      add_column :bootcampers, :middle_name, :string
    end

    unless column_exists? :bootcampers, :avatar
      add_column :bootcampers, :avatar, :string
    end
  end
end
