RSpec.shared_examples "prevent non admins from performing CRUD" do
  before do
    controller.stub(admin?: false)
  end

  context "when the user is a non-admin" do
    it "redirects them to content management page without edit action" do
      expect do
        redirect_to content_management_path
      end
    end
  end
end
