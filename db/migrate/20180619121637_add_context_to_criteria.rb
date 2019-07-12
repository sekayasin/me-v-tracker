class AddContextToCriteria < ActiveRecord::Migration[5.0]
  def change
    unless column_exists? :criteria, :context
      add_column :criteria, :context, :string
    end
  end
end
