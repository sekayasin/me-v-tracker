class AddCreatedByIdToPitches < ActiveRecord::Migration[5.0]
  def change
    add_column :pitches, :created_by, :integer
  end
end
