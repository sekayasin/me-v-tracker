class AddNoShowToDecisionStatus < ActiveRecord::Migration[5.0]
  def change
    Rake::Task["db:add_no_show_row_in_decison_status_table"].invoke
  end
end
