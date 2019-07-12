class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.string :recipient_email
      t.references :notifications_message, foreign_key: true
      t.boolean :is_read

      t.timestamps
    end
  end
end
