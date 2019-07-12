require "rails_helper"

RSpec.describe PitchController, type: :controller do
  let(:user) { create :user }

  before(:each) do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
    @bootcamper = create_list(:bootcamper, 10)
    @cycle_center = create(:cycle_center, :start_today)
    @learner = @bootcamper.map do |camper|
      create(
        :learner_program,
        camper_id: camper.camper_id,
        cycle_center_id: @cycle_center.cycle_center_id
      )
    end
    @valid_params = {
      cycle_center_id: @cycle_center.cycle_center_id,
      demo_date: Date.tomorrow,
      lfa_email: [
        "efe.efey@andela.com",
        "yes.yes@andela.com"
      ],
      camper_id: @learner.map(&:camper_id),
      created_by: session[:current_user_info][:email]
    }

    @pitch = create(
      :pitch,
      cycle_center_id: @cycle_center.id,
      demo_date: Date.tomorrow,
      created_by: user.user_info[:email]
    )
  end

  describe "POST #create" do
    it " creates a pitch" do
      post :create, params: @valid_params

      expect(response).to have_http_status(:success)
      expect(response.body).to include "Pitch successfully created"
    end
  end

  describe "PUT #update" do
    it "update a pitch" do
      put :update, params: {
        pitch_id: @pitch.id,
        demo_date: Date.tomorrow,
        cycle_center_id: @cycle_center.cycle_center_id,
        lfa_email: ["new.panelist@andela.com"],
        camper_id: @learner.map(&:camper_id),
        program_id: 4,
        updates: {
          program: false,
          cycle_center: false,
          added_panelists: [],
          removed_panelists: [],
          demo_date: false
        },
        center_name: "Lagos",
        cycle_number: 45
      }

      expect(response).to have_http_status(:success)
      expect(response.body).to include "Pitch successfully updated"
    end
  end
end
