class RemoveUniqueConstraintOnOutputSubmissions < ActiveRecord::Migration[5.0]
  def change
    remove_index "output_submissions", name: "unique_output_link"
  end
end
