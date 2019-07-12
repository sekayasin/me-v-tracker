require "rails_helper"

RSpec.describe GcpService, type: :service do
  before(:all) do
    @bucket = GcpService::LEARNER_SUBMISSIONS_BUCKET
    @connection = Fog::Storage.new(
      provider: "AWS",
      aws_access_key_id: "access key",
      aws_secret_access_key: "secret key"
    )
  end

  context "test minio connection" do
    it "it returns true if minio is connected" do
      expect(GcpService.minio_connected?(@bucket, @connection)).to eq true
    end

    it "it returns true if not found exception is thrown" do
      expect(GcpService.minio_connected?("no-bucket", @connection)).to eq true
    end

    it "it returns false if minio is not connected" do
      expect(GcpService.minio_connected?(@bucket)).to eq false
    end
  end

  context "get fog connection configuration" do
    before(:each) do
      allow(GcpService).to receive(:minio_connected?).and_return(true)
    end

    before(:each, :dev) do
      allow(Rails).to receive(:env).and_return("development")
    end

    before(:each, :minio_disconnected) do
      allow(GcpService).to receive(:minio_connected?).and_return(false)
    end

    it "it returns aws fog class if environment is develop", :dev do
      fog_class = GcpService.get_connection(@bucket).class
      expect(fog_class).to eq Fog::Storage::AWS::Real
    end

    it "it returns google fog class if environment is not develop" do
      fog_class = GcpService.get_connection(@bucket).class
      expect(fog_class).to eq Fog::Storage::Google::Real
    end

    it "it raises exception if minio is down", :dev, :minio_disconnected do
      expect { GcpService.get_connection(@bucket) }.to raise_error(RuntimeError)
    end
  end

  context "upload file" do
    before do
      allow(GcpService).to receive(:get_connection).and_return(@connection)
      @connection.put_bucket(@bucket)
    end

    it "it should upload image successfully" do
      file_link = GcpService.upload("sample_file", "sample_file", @bucket)
      link =
        "https://storage.googleapis.com/learner-submission-uploads-staging/" \
        "sample_file"

      expect(file_link).to eq link
    end
  end

  context "delete file" do
    before do
      allow(GcpService).to receive(:get_connection).and_return(@connection)
    end

    it "it should delete image successfully" do
      link =
        "https://storage.googleapis.com/learner-submission-uploads-staging/" \
        "sample_file"
      delete = GcpService.delete(@bucket, link)
      expect(delete.status).to eq 204
    end
  end

  context "download file" do
    before do
      allow(GcpService).to receive(:get_connection).and_return(@connection)
      @connection.put_bucket(@bucket)
      GcpService.upload("sample_file", "sample_file", @bucket)
    end

    it "it should download file successfully" do
      response = GcpService.download(@bucket, "sample_file")
      expect(response.status).to eq 200
    end
  end
end
