module Dashboard
  class DashboardFacade
    def initialize(report_type, data)
      @report_type = report_type.to_sym
      @data = data
    end

    def create_zip_folder(folder_name, report_data)
      file_name = "#{folder_name}.zip"
      Zip::File.open(file_name, Zip::File::CREATE) do |zipfile|
        report_data.each do |csv_file_name, report|
          zipfile.get_output_stream("#{csv_file_name}.csv") do |file|
            file.write report
          end
        end
      end
      file_name
    end

    def generate_report
      case @report_type
      when :program_metrics
        report_data = ProgramMetricsFacade.new(@data).report_data
        create_zip_folder("program_metrics_csv", report_data)
      when :cycle_metrics
        report_data = CycleCenterMetricsFacade.new(@data).report_data
        create_zip_folder("cycle_center_metrics_csv", report_data)
      end
    end
  end
end
