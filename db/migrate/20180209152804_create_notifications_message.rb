class CreateNotificationsMessage < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications_messages do |t|
      t.string :content
      t.string :priority

      t.timestamps
    end
  end
end
