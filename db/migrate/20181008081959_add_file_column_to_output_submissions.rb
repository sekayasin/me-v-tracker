class AddFileColumnToOutputSubmissions < ActiveRecord::Migration[5.0]
  def change
    add_column :output_submissions, :file_link, :text
    add_column :output_submissions, :file_name, :text
  end
end
