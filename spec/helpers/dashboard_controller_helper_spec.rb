require "rails_helper"

RSpec.describe DashboardControllerHelper, type: :helper do
  let(:parameters) do
    "cycles_centers.end_date BETWEEN '2018-04-04'\n        AND '2018-04-04'"
  end

  describe "GET #validate_date_params" do
    context "when start_date and end_date are provided" do
      it "returns is a string with dates and program id" do
        params = {
          program_id: 1,
          start_date: "2018-04-04",
          end_date: "2018-04-04"
        }
        expect(validate_date_params(params)).to include "2018-04-04"
        expect(validate_date_params(params)).to include "2018-04-04"
      end
    end

    context "when start_date and end_date are not provided" do
      it "has todays' date in the string" do
        params = {
          program_id: 1,
          start_date: "",
          end_date: ""
        }
        expect(validate_date_params(params)).to include "1"
      end
    end
  end

  describe "GET #validate_date_params" do
    context "when start_date and end_date are provided" do
      it "returns is a string with dates and program id" do
        params = {
          start_date: "2018-04-04",
          end_date: "2018-04-04"
        }
        expect(validate_date_params(params).to_s).to eq(parameters.to_s)
      end
    end

    context "when start_date and end_date are not provided" do
      it "just has the program_id" do
        params = {
          program_id: 1,
          start_date: "",
          end_date: ""
        }
        expect(validate_date_params(params)).to include params[:program_id].to_s
      end
    end
  end

  describe "GET #learners_dispersion_data" do
    context "when start_date and end_date are provided" do
      it "returns an hash that contains chart data" do
        params = {
          program_id: 1,
          start_date: "2018-04-04",
          end_date: "2018-04-04"
        }
        expect(learners_dispersion_percentages(params)).to have_key(:centers)
        expect(
          learners_dispersion_percentages(params)
        ).to have_key(:percentages)
        expect(learners_dispersion_percentages(params)).to have_key(:colors)
        expect(learners_dispersion_percentages(params)).to have_key(:totals)
      end
    end
  end
end
