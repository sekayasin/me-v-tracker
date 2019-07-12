class AddSocialLinksToBootcampers < ActiveRecord::Migration[5.0]
  def change
    add_column :bootcampers, :trello, :string
    add_column :bootcampers, :github, :string
    add_column :bootcampers, :linkedin, :string
    add_column :bootcampers, :website, :string
  end
end
