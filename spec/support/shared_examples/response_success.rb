RSpec.shared_examples "response success" do |method, template|
  let(:user) { create :user }

  before do
    stub_current_user(:user)
    send(method, template)
  end

  context "when route exist successful" do
    it "responds with status 200" do
      expect(response.status).to eq 200
    end

    it "renders template" do
      expect(response).to render_template template
    end
  end
end
