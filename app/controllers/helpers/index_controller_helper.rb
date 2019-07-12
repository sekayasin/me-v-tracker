module IndexControllerHelper
  def render_learners_csv(filters)
    set_streaming_headers
    set_file_headers
    self.response_body = csv_lines(filters)
    response.status = 200
  end

  def set_file_headers
    filename = "bootcampers-#{Date.today}.csv"
    headers["Content-Type"] = "text/csv"
    headers["Content-Disposition"] = "attachment; filename=#{filename}"
  end

  def set_streaming_headers
    headers.delete("Content-Length")
    headers["Cache-Control"] = "no-cache"
    headers["X-Accel-Buffering"] = "no"
  end

  def csv_lines(filter_params)
    Enumerator.new do |csv|
      BootcampersCsvService.generate_report(filter_params) do |data|
        csv << data.to_s
      end
    end
  end
end
