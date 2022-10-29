Cloudinary.config do |config|
  config.cloud_name = Rails.application.credentials.cloudinary.cd_cloud_name!
  config.api_key = Rails.application.credentials.cloudinary.cd_api_key!
  config.api_secret = Rails.application.credentials.cloudinary.cd_api_secret!
  config.secure = true
end
