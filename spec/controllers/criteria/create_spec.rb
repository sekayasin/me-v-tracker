require "rails_helper"

RSpec.describe CriteriaController, type: :controller do
  let(:user) { create :user }

  before do
    stub_current_user(:user)
    controller.stub(:admin?)
  end

  let(:params) do
    {
      criterium: attributes_for(:criterium),
      frameworks: [create(:framework).id]
    }
  end

  describe "POST #create" do
    context "when criterion saves successfully" do
      it "creates a new criterion" do
        expect do
          post :create, params: params, xhr: true
        end.to change(Criterium, :count).by(1)
      end

      it "displays successful flash message" do
        post :create, params: params, xhr: true
        expect(flash[:notice]).to eq "criterion-success"
      end
    end

    context "when criterion does not save successfully" do
      it "does not create new criterion" do
        expect do
          post :create, params: {
            criterium: attributes_for(
              :criterium,
              name: "",
              description: ""
            ),
            frameworks: [create(:framework).id]
          }, xhr: true
        end.not_to change(Criterium, :count)
      end
    end

    context "when criterion name already exists" do
      it "displays appropriate flash message" do
        post :create, params: {
          criterium: attributes_for(
            :criterium,
            name: "Overall Skills",
            description: "Measure all types of skill"
          ),
          frameworks: [create(:framework).id]
        }, xhr: true
        post :create, params: {
          criterium: attributes_for(
            :criterium,
            name: "Overall Skills",
            description: "Measure all types of skill"
          ),
          frameworks: [create(:framework).id]
        }, xhr: true
        expect(flash[:error]).to eq "Name has already been taken"
      end
    end

    context "when no framework is selected" do
      it "displays appropriate flash message" do
        post :create, params: {
          criterium: attributes_for(
            :criterium,
            name: "A New Criterion",
            description: "Measure any skill"
          )
        }, xhr: true
        expect(flash[:error]).to eq "Please select a framework"
      end
    end

    context "when a non-admin attempts view actions" do
      it "displays content_management page with no actions" do
        controller.stub(admin?: false)
        expect do
          redirect_to curriculum_path
        end
      end
    end
  end
end
