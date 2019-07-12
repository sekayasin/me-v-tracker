class AddDevFrameworkFlagToCriterium < ActiveRecord::Migration[5.0]
  def change
    add_column :criteria, :belongs_to_dev_framework, :boolean, :default => false

    Rake::Task["app:update_dev_framework_flags"].invoke
  end
end
