require "rails_helper"

RSpec.describe LearnersControllerHelper, type: :helper do
  include LearnerProfileHelper

  let(:session_picture) { "path/to/session/image.png" }
  let(:db_avatar) { "path/to/avatar/image.png" }
  let(:learner) { create :bootcamper_with_learner_program, avatar: nil }
  let!(:params) do
    (attributes_for :bootcamper).slice(
      :username, :github, :linkedin, :trello, :website
    )
  end
  let!(:image_file) { edit_upload_image_file }
  let!(:get_learner) { { camper_id: learner[:camper_id] } }
  let(:session_learner) do
    {
      email: learner[:email],
      picture: session_picture
    }
  end

  before do
    stub_non_andelan
    session[:current_user_info] = session_learner
  end

  describe ".exact_value" do
    it "returns nil" do
      expect(exact_value("").nil?).to eq(true)
      expect(exact_value("-").nil?).to eq(true)
    end

    it "returns string 'Hello'" do
      expect(exact_value("Hello")).to eq("Hello")
    end
  end

  describe ".get_learner_image" do
    it "returns learner picture from session" do
      expect(get_learner_image).to eq(session_picture)
    end

    it "returns learner picture from database" do
      update_bootcamper_avatar(learner[:camper_id], db_avatar)
      expect(get_learner_image).to eq(db_avatar)
    end
  end

  describe ".validate_username_field" do
    it "returns an array containing 'username'" do
      params["username"] = "vof234.,"
      expect(validate_username_field(params)).to eq(%w(username))
    end
  end

  describe ".country_code" do
    it "returns 'NG', UG and KE" do
      expect(country_code("Nigeria")).to eq("NG")
      expect(country_code("Uganda")).to eq("UG")
      expect(country_code("Kenya")).to eq("KE")
    end
  end

  describe ".validate_phone_number" do
    it "returns true or false for phone_number" do
      expect(validate_phone_number("09021208953", "Nigeria")).to eq(true)
      expect(validate_phone_number("456021208953", "Nigeria")).to eq(false)
    end
  end

  describe ".extract_link_host" do
    it "returns https://github.com" do
      expect(extract_link_host("https://github.com/learner")).
        to eq("https://github.com")
    end
  end

  describe ".validate_link_fields" do
    it "returns empty errors array" do
      expect(validate_link_fields(params)).to eq(%w())
    end

    it "returns errors array" do
      params["github"] = "https://github.com/learner/errored"
      expect(validate_link_fields(params)).to eq(%w(github))
      params["github"] = "https://github.com/learner"
      expect(validate_link_fields(params)).to eq(%w())
    end
  end

  describe ".validate_learner_image" do
    it "returns nil" do
      expect(validate_learner_image(nil).nil?).to eq(true)
    end

    it "returns true" do
      image_file.set_filename("filename.png")
      image_file.set_size(500_000)
      expect(validate_learner_image(image_file)).to eq(true)
    end

    it "returns image-extension" do
      image_file.set_filename("filename.pdf")
      expect(validate_learner_image(image_file)).to eq(%w(image-extension))
    end
  end

  describe ".learner_image_filename" do
    it "returns generated jpeg image filename" do
      image_file.set_filename("filename.jpg")
      expect(learner_image_filename).to eq("IMG#{learner[:camper_id]}.jpg")

      image_file.set_filename("filename.png")
      expect(learner_image_filename).to eq("IMG#{learner[:camper_id]}.jpg")
    end
  end

  describe ".image_to_thumbnail_buffer" do
    it "returns nil" do
      image_file.set_filename("filename.jpg")
      image_file.set_size(500_000)
      expect(image_to_thumbnail_buffer(nil)).to eq(nil)
    end
  end

  describe ".save_personal_details" do
    it "ensures username and links are updated " do
      save_personal_details(params)
      bootcamper = Bootcamper.find_by(camper_id: learner[:camper_id])
      expect(bootcamper[:username]).to eq(params[:username])
      expect(bootcamper[:github]).to eq(params[:github])
      expect(bootcamper[:linkedin]).to eq(params[:linkedin])
      expect(bootcamper[:website]).to eq(params[:website])
      expect(bootcamper[:trello]).to eq(params[:trello])
    end
  end
end
