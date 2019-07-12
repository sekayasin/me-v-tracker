require "fog/google"
require "fog/aws"

module GcpService
  def self.env_bucket(bucket)
    return bucket if Rails.env == "production"

    "#{bucket}-staging"
  end

  GCP_ID = ENV["GOOGLE_STORAGE_ACCESS_KEY_ID"]
  GCP_SECRET = ENV["GOOGLE_STORAGE_SECRET_ACCESS_KEY"]
  PROFILE_PICTURES_BUCKET = env_bucket("alc-profile-pictures").freeze
  LEARNER_SUBMISSIONS_BUCKET = env_bucket("learner-submission-uploads").freeze
  SURVEY_MEDIA_BUCKET = env_bucket("survey-media").freeze

  minio_url = "http://localhost:9000/"
  gcp_url = "https://storage.googleapis.com/"

  @base_url = Rails.env == "development" ? minio_url : gcp_url

  @gcp_connection = Fog::Storage.new(
    provider: "Google",
    google_storage_access_key_id: GCP_ID,
    google_storage_secret_access_key: GCP_SECRET
  )

  @minio_connection = Fog::Storage.new(
    provider: "AWS",
    aws_access_key_id: GCP_ID,
    aws_secret_access_key: GCP_SECRET,
    host: "localhost",
    endpoint: minio_url,
    path_style: true
  )

  def self.minio_connected?(bucket, connection = @minio_connection)
    connection.get_bucket(bucket)
    true
  rescue Excon::Error::NotFound
    true
  rescue Excon::Error::Socket
    false
  end

  def self.get_connection(bucket)
    if Rails.env == "development"
      if minio_connected?(bucket)
        return @minio_connection
      else
        raise <<-MINIO
           File upload failed because Minio Server is down. Visit https://github.com/andela/vof-tracker/pull/1217 for setup instruction.
        MINIO
      end
    end
    @gcp_connection
  end

  def self.upload(filename, buffer, bucket)
    connection = get_connection(bucket)
    response = connection.put_object(
      bucket,
      filename,
      buffer
    )
    if response
      "#{@base_url}#{bucket}/#{filename}"
    end
  end

  def self.delete(bucket, file_link)
    if file_link
      connection = get_connection(bucket)
      file_name_id = file_link.split("/")[-1]
      connection.delete_object(
        bucket,
        file_name_id
      )
    end
  rescue Excon::Error::NotFound
  end

  def self.download(bucket, file_name_id)
    connection = get_connection(bucket)
    connection.get_object(bucket, file_name_id)
  rescue Excon::Error::NotFound
  end
end
