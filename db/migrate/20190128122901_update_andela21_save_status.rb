class UpdateAndela21SaveStatus < ActiveRecord::Migration[5.0]
  def change
    Rake::Task["app:set_andela21_save_status"].invoke
  end
end
