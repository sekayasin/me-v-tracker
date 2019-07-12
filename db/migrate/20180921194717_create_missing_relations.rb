class CreateMissingRelations < ActiveRecord::Migration[5.0]
  def change
    Rake::Task['app:create_missing_relations_kla_12'].invoke
  end
end
