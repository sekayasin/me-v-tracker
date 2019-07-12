class CreateCenters < ActiveRecord::Migration[5.0]
    def up
      create_table :centers, id: false do |t|
        t.string :center_id, primary: true, index: true
        t.string :name
        t.string :country

        t.timestamps
      end
      Rake::Task["db:populate_centers_table"].invoke
    end

    def down
        drop_table(:centers, if_exists: true)
    end
end