load "spreadsheet_validation_service.rb"

class SpreadsheetService
  include SpreadsheetValidationService
  def initialize(file)
    @sheet = Roo::Spreadsheet.open(file)
  end

  def sheet_data
    @sheet
  end

  def validate_spreadsheet(spreadsheet_data)
    header_errors = validate_headers[:invalid]
    return { headers: header_errors, error: true } unless header_errors.blank?

    _ = validate_body(spreadsheet_data)
  end

  private

  def camper_params(row)
    {
      first_name: row[0].value.strip,
      last_name: row[1].value.strip,
      email: sanitize_field(row[2].value.strip),
      gender: row[3].value.titleize.strip,
      greenhouse_candidate_id: row[5].value.to_i.to_s.strip
    }
  end

  def learner_program_params(row, spreadsheet_data)
    {
      week_one_lfa: row[4] ? sanitize_field(row[4].value.strip) : ""
    }.merge(spreadsheet_data[0])
  end

  def error_rows(invalid_fields)
    columns = []
    invalid_fields.each do |row|
      columns.push(required_headers[row[1].column - 1])
    end

    {
      row: invalid_fields,
      columns: columns
    }
  end

  def required_headers
    [
      "First Name",
      "Last Name",
      "Email",
      "Gender",
      "LFA",
      "Greenhouse Candidate Id"
    ]
  end

  def validate_headers
    headers = sheet_data.row(1)
    header_errors = missing_headers(headers)

    return header_errors if header_errors[:missing]

    (0..5).each do |index| # for wrong && swapped header names
      unless required_headers[index].casecmp(headers[index].to_s).zero?
        header_errors[:invalid].push(required_headers[index])
      end
    end

    header_errors
  end

  def missing_headers(sheet_headers)
    header_errors = { invalid: [], missing: false }
    sheet_headers.compact! if sheet_headers.any?(&:nil?)
    sheet_headers.map!(&:downcase)

    if sheet_headers.length < 6
      header_errors[:missing] = true
      header_errors[:invalid] = required_headers.map(&:downcase) - sheet_headers
    end

    header_errors
  end
end
