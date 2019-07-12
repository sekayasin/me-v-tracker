class AddPerformanceAndTargetData < ActiveRecord::Migration[5.0]
  def up
    Rake::Task["app:update_performance_and_output_targets"].invoke
    Rake::Task["app:populate_program_years_target_data"].invoke
  end

  def down
    ProgramYear.offset(1).each { |program_year| program_year.delete }
    Year.offset(1).each { |year| year.delete }
  end
end
