require "rails_helper"

RSpec.describe IndexController, type: :controller do
  let(:user) { create :user, :admin }
  let(:lfa) { create :user, :facilitator }
  let(:center) { create :center }
  let!(:bootcamper_one) { create :bootcamper }
  let!(:bootcamper_two) { create :bootcamper }
  let!(:facilitator) do
    create :facilitator, email: "oluwatomi.duyile@andela.com"
  end
  let!(:program) { create :program }
  let!(:learner_program_one) do
    create(
      :learner_program,
      program: program,
      camper_id: bootcamper_one.camper_id,
      week_one_facilitator: facilitator
    )
  end
  let!(:learner_program_two) do
    create(
      :learner_program,
      program: program,
      camper_id: bootcamper_two.camper_id
    )
  end
  def populate_dashboard
    get :index, params: { city: "All",
                          cycle: "All",
                          week_one_lfa: "All",
                          week_two_lfa: "All",
                          decision_one: "All",
                          decision_two: "All",
                          page: 1,
                          num_pages: 3,
                          page_size: 15,
                          program_id: program.id }
  end

  before do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info.to_h
    populate_dashboard
  end

  describe "GET #index" do
    context "when format is html" do
      it "renders index template" do
        expect(response).to render_template(:index)
      end

      it "responds to html format" do
        expect(response.content_type).to eq Mime[:html]
      end
    end

    context "when the template is rendered" do
      it "contains the dashboard instance variable" do
        expect(assigns(:dashboard)).to_not eq nil
      end

      it "returns the campers instance variable" do
        expect(assigns(:campers)).to_not eq nil
      end
    end
  end

  describe ".private methods" do
    @controller = IndexController.new
    context "get sort option" do
      let(:params) do
        {
          first_name: "name",
          value_average: "values",
          output_average: "output",
          feedback_average: "feedback",
          overall_average: "overall_average"
        }
      end
      it("returns the sort value selected") {
        params.each do |key, value|
          @controller.params = ActionController::Parameters.new(sort: value)
          sort = @controller.instance_eval { get_sort_option }
          expect(sort).to eq key
        end
      }
    end
  end

  describe "populate lfa dashboard" do
    before do
      session[:current_user_info] = lfa.user_info.to_h
      populate_dashboard
    end
    context "populating lfa dashboard" do
      it "loads campers based on the lfa" do
        expect(assigns(:campers).length).to eq 1
      end

      it "loads camper assigned to the specific lfa" do
        expect(assigns(:campers)[0][:camper_id]).to eq bootcamper_one.camper_id
      end
    end
  end

  describe "GET #get_cities" do
    before do
      center
    end

    context "when user tries to selects a country" do
      it "returns all center cities in that country" do
        get :get_cities, params: {
          country: center.country
        }
        cities = JSON.parse(response.body)
        expect(cities.length).should_not be_nil
        expect(cities[0]).to eq center.name
      end
    end
  end

  describe "GET #sheet" do
    context "when dashboard is populated " do
      it "sorts campers by most recent upload" do
        expect(assigns(:campers)[0][:camper_id]).to eq bootcamper_two.camper_id
      end

      it "populates dashboard with admin data" do
        expect(assigns(:campers).length).to eq 2
      end
    end

    context "when format is csv" do
      let(:csv_filename) { { filename: "bootcampers-#{Date.today}.csv" } }
      let(:first_csv_header) do
        csv = []
        BootcampersCsvService.generate_report(
          program_id: program.id,
          city: "All",
          cycle: "All",
          week_one_lfa: "All",
          week_two_lfa: "All",
          decision_one: "Advanced",
          decision_two: "All"
        ) { |data| csv << data.to_s }
        csv
      end

      before do
        stub_allow_admin
        stub_export_csv
        get :sheet, format: :csv, params: { program_id: program.id }
      end

      it "has access to the send_data method" do
        expect(controller).to receive(:send_data).
          with(csv_filename, first_csv_header)
        controller.send_data(csv_filename, first_csv_header)
      end

      it "responds with the right headers" do
        expect(response.headers["Content-Type"]).to include "text/csv"
        expect(
          response.headers["Content-Disposition"].to_s
        ).to include csv_filename[:filename]
        expect(response.headers["Cache-Control"]).to eql "no-cache"
        expect(response.headers["X-Accel-Buffering"]).to eql "no"
        expect(response.headers["Content-Length"].present?).to eql false
      end
    end
  end
end
