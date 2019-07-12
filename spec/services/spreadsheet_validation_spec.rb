require "rails_helper"

RSpec.describe SpreadsheetService do
  let!(:bootcampers) { create_list(:bootcamper, 4) }
  let(:spreadsheet) { Class.new { extend SpreadsheetValidationService } }
  let(:spreadsheetService) do
    SpreadsheetService.new(
      Rails.root.join("spec/fixtures/invalidlearnerbody.xlsx").to_s
    )
  end

  describe ".deduplicate_data" do
    context "when adding learners" do
      it "returns duplicate email address" do
        bootcampers[0].email = bootcampers[1].email
        duplicate_email = spreadsheet.deduplicate_data(
          bootcampers, :email
        )
        expect(duplicate_email).not_to be_empty
      end

      it "returns no duplicate email address" do
        duplicate_email = spreadsheet.deduplicate_data(
          bootcampers, :email
        )
        expect(duplicate_email).to be_empty
      end

      it "returns duplicate greenhouse ids" do
        greenhouse_id = bootcampers[0].greenhouse_candidate_id
        bootcampers[1].greenhouse_candidate_id = greenhouse_id
        duplicate_ids = spreadsheet.deduplicate_data(
          bootcampers, :greenhouse_candidate_id
        )
        expect(duplicate_ids).not_to be_empty
      end
    end
  end

  describe ".sheet_data" do
    let(:spreadsheetService) do
      SpreadsheetService.new(
        Rails.root.join("spec/fixtures/samplelearner.xlsx").to_s
      )
    end

    context "reads .xlsx spreadsheet " do
      it {
        expect(spreadsheetService.sheet_data).not_to be_nil
      }
    end
  end

  describe ".create_empty_cells" do
    subject(:spreadsheet) { Class.new { extend SpreadsheetValidationService } }

    context "when a row is encountered with nil values" do
      it "converts the nil values to empty Roo objects" do
        row = spreadsheetService.create_empty_cells(
          spreadsheetService.sheet_data.row(2), 2
        )
        expect(row.any?(&:nil?)).to eq false
      end
    end
  end

  describe "validation mathods" do
    let(:emptyCoordinate) do
      Roo::Excelx::Cell::Empty.new(
        Roo::Excelx::Coordinate.new(1, 2)
      )
    end
    let(:validCoordinate) do
      Roo::Excelx::Cell::String.new("none", nil, 4, nil,
                                    Roo::Excelx::Coordinate.new(1, 2))
    end
    let(:validGreenhouseID) do
      Roo::Excelx::Cell::String.new("12345679", nil, 4, nil,
                                    Roo::Excelx::Coordinate.new(1, 2))
    end

    context "when a row with missing fields is encountered" do
      it "informs the user that the first name is missing" do
        response = spreadsheetService.send(:validate_field, emptyCoordinate, 0)
        expect(response).to include "First name is missing"
      end

      it "informs the user that the last name is missing" do
        response = spreadsheetService.send(:validate_field, emptyCoordinate, 1)
        expect(response).to include "Last name is missing"
      end

      it "informs the user that the bootcamper's email is missing" do
        response = spreadsheetService.send(:validate_field,
                                           emptyCoordinate, 2)
        expect(response).to include "Learner Email missing"
      end
      it "informs the user that the bootcamper's email is invalid" do
        response = spreadsheetService.send(:validate_field,
                                           validCoordinate, 2)
        expect(response).to include "Email is invalid"
      end
      it "informs the user that the bootcamper's LFA's email is missing" do
        response = spreadsheetService.send(:validate_field,
                                           emptyCoordinate, 4)
        expect(response).to include "LFA is missing for this learner"
      end
      it "informs the user that LFA email is invalid" do
        response = spreadsheetService.send(:validate_field,
                                           validCoordinate, 4)
        expect(response).to include "LFA has an invalid Andela email"
      end

      it "informs the user that the gender is missing" do
        response = spreadsheetService.send(:validate_field,
                                           emptyCoordinate, 3)
        expect(response).to include "Gender is missing"
      end

      it "informs the user that a wrong value was entered in the gender
      field" do
        response = spreadsheetService.send(:validate_field, validCoordinate, 3)
        expect(response).to include(
          "A wrong value was entered in the gender field"
        )
      end

      it "informs the user that the greenhouse ID is missing" do
        response = spreadsheetService.send(:validate_field,
                                           emptyCoordinate, 5)
        expect(response).to include "Greenhouse ID is either empty or of the "\
        "wrong length"
      end
    end
  end

  describe ".validate_body" do
    context "when validate_body is called" do
      it "returns errors found in a sheet if there are any" do
        spreadsheet_data = [[], spreadsheetService.sheet_data]
        response = spreadsheetService.send(:validate_body, spreadsheet_data)
        expect(response).to include(:rows, error: true)
      end
    end
  end
end
