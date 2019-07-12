require "assets/sanitize_id"

module SpreadsheetValidationService
  def deduplicate_data(learners, field)
    valid_data = []
    duplicates = []

    learners.each do |learner|
      if valid_data.include?(learner[field])
        duplicates << learner[field]
      else
        valid_data << learner[field]
      end
    end

    duplicates
  end

  def create_empty_cells(row, current_row)
    row.map.with_index do |val, index|
      val || Roo::Excelx::Cell::Empty.new(
        Roo::Excelx::Coordinate.new(current_row, index + 1)
      )
    end
  end

  private

  def validate_body(spreadsheet_data)
    @learners = []
    @learner_programs = []
    @rows_with_errors = []
    @existing_users = []

    iterate_rows(spreadsheet_data)

    if @rows_with_errors.blank?
      resolve_duplicates
    else
      { error: true, rows: @rows_with_errors }
    end
  end

  def iterate_rows(spreadsheet_data)
    current_row = 2
    spreadsheet_data[1].each_row_streaming(offset: 1, pad_cells: true) do |row|
      # handle issue where GH IDs are the only cell deleted
      row << nil if row.count == 5
      row = create_empty_cells(row, current_row) if row.any?(&:nil?)
      current_row += 1
      filter_out_row_errors(row, spreadsheet_data)
    end
  end

  def filter_out_row_errors(row, spreadsheet_data)
    error_fields = validate_row(row)
    if error_fields.blank?
      create_learner(row, spreadsheet_data) unless empty_or_nil?(row)
    else
      @rows_with_errors << error_rows(error_fields)
    end
  end

  def create_learner(row, spreadsheet_data)
    if learner_exists?(row[2], spreadsheet_data)
      @existing_users.push(
        email: sanitize_field(row[2].value),
        cycle: spreadsheet_data[0][:cycle]
      )
    else
      @learners << camper_params(row)
      @learner_programs << learner_program_params(
        row, spreadsheet_data
      )
    end
  end

  def duplicates
    emails = deduplicate_data(@learners, :email)
    ids = deduplicate_data(
      @learners,
      :greenhouse_candidate_id
    )
    [emails, ids] if emails.present? || ids.present?
  end

  def resolve_duplicates
    if duplicates.blank?
      {
        error: false,
        bootcampers: @learners,
        learner_programs: @learner_programs,
        existing: @existing_users
      }
    else
      {
        error: true,
        email_duplicates: duplicates[0],
        id_duplicates: duplicates[1]
      }
    end
  end

  def empty_or_nil?(row)
    row[0...6].empty? || row[0...6].any? { |info| info.value.nil? }
  end

  def sanitize_field(email)
    Nokogiri::HTML(email).xpath("//text()").to_s
  end

  def current_row_fields(row)
    @email = sanitize_field(row[2].value) unless row[2].blank?
    @greenhouse_id = row[5].value unless row[5].blank?
  end

  def validate_row(row)
    error_fields = []
    blank_fields = row.select(&:blank?).length

    return error_fields if blank_fields == row.length

    current_row_fields(row)

    row[0...6].each_with_index do |field, index|
      error = validate_field(field, index)
      error_fields.push(error) unless error.nil?
    end

    error_fields
  end

  def validate_field(field, index)
    if [0, 1].include?(index)
      validate_name(field, index)
    elsif index == 2
      validate_learner_email(field, index)
    elsif index == 3
      validate_gender(field)
    elsif index == 4
      validate_field_email(field, index)
    elsif index == 5
      validate_greenhouse_id(field)
    end
  end

  def validate_name(field, index)
    if field.blank? && index.zero?
      ["First name is missing", field.coordinate]
    elsif field.blank? && index == 1
      ["Last name is missing", field.coordinate]
    end
  end

  def validate_email_helper(field)
    unless field.value.blank?
      sanitize_field(field.value.strip)
    end
  end

  def validate_learner_email(field, index)
    email = validate_email_helper(field)
    unless email.to_s.match?(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
      if index == 2 && field.value.nil?
        ["Learner Email missing", field.coordinate]
      else
        ["Email is invalid", field.coordinate]
      end
    end
  end

  def validate_field_email(field, index)
    email = validate_email_helper(field)
    unless email.to_s.match?(/^((?!\.)[a-z0-9._%+-]+(?!\.)\w)@andela\.com$/i)
      if index == 4 && field.value.nil?
        ["LFA is missing for this learner", field.coordinate]
      elsif index == 4
        ["LFA has an invalid Andela email", field.coordinate]
      else
        ["Email is invalid", field.coordinate]
      end
    end
  end

  def validate_gender(field)
    return ["Gender is missing", field.coordinate] if field.value.nil?

    gender = %w[male female]
    unless gender.include?(field.value.downcase)
      ["A wrong value was entered in the gender field",
       field.coordinate]
    end
  end

  def validate_greenhouse_id(field)
    field_value = sanitize_id(field.value.to_s).chop

    if field.blank? || !field_value.length.between?(7, 11)
      ["Greenhouse ID is either empty or of the wrong length", field.coordinate]
    end
  end

  def learner_exists?(email, spreadsheet_data)
    return false if email.blank?

    center = spreadsheet_data[0][:city]
    cycle = spreadsheet_data[0][:cycle].to_i
    program_id = spreadsheet_data[0][:program_id]
    email = sanitize_field(email.value)

    bootcamper = Bootcamper.find_by_email(email)

    return false if bootcamper.nil?

    learner = bootcamper.learner_programs.
              joins(cycle_center: :cycle).
              joins(cycle_center: :center).
              where(
                program_id: program_id,
                cycles: { cycle: cycle },
                centers: { name: center }
              )

    !learner.empty?
  end
end
