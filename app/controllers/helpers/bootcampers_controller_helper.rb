module BootcampersControllerHelper
  def learner_info
    prepare_learner_info(bootcampers_params)
  end

  def check_nil(bootcamper, learner_program)
    return [bootcamper, learner_program] unless bootcamper.nil?

    false
  end

  private

  def prepare_learner_info(bootcampers_params)
    d = Date.parse(bootcampers_params["end_date"])
    @learner_program = {
      program_id: bootcampers_params["program_id"],
      country: bootcampers_params["country"],
      city: bootcampers_params["city"].capitalize,
      cycle: bootcampers_params["cycle"],
      start_date: Date.parse(bootcampers_params["start_date"]),
      end_date: Time.new(d.year, d.month, d.day, 23, 59, 59, "+00:00"),
      dlc_stack_id: bootcampers_params["dlc_stack_id"]
    }
    spreadsheet = SpreadsheetService.new(bootcampers_params[:file])
    [@learner_program, spreadsheet.sheet_data, spreadsheet]
  end
end
