require "rails_helper"

RSpec.describe SpreadsheetService do
  describe ".validate spreadsheet" do
    let(:spreadsheetService) do
      SpreadsheetService.new(
        Rails.root.join("spec/fixtures/no email column.xlsx").to_s
      )
    end

    context "validation fails for missing header columns" do
      it {
        expect(
          spreadsheetService.validate_spreadsheet(spreadsheetService.sheet_data)
        ).to include(headers: ["email"], error: true)
      }
    end

    context "validation fails for swapped header columns" do
      let(:spreadsheetService) do
        SpreadsheetService.new(
          Rails.root.join("spec/fixtures/swapped header columns.xlsx").to_s
        )
      end
      it {
        expect(
          spreadsheetService.validate_spreadsheet(spreadsheetService.sheet_data)
        ).to include(headers: %w(Email Gender), error: true)
      }
    end
  end
end
