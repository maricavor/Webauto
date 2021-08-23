CarrierWave.configure do |config|
    # Use local storage if in development or test
     if Rails.env.development? || Rails.env.test?
       CarrierWave.configure do |config|
         config.storage = :file
       end
     end

     # Use AWS storage if in production
     if Rails.env.production?
       CarrierWave.configure do |config|
         config.storage = :fog
       end
     end
    #config.enable_processing = true
    #config.root = ENV['OPENSHIFT_DATA_DIR']
    #config.cache_dir = config.root + 'uploads'
    config.fog_credentials = {
          :provider               => 'AWS',
          :aws_access_key_id      => "",
          :aws_secret_access_key  => "",
          :region                 => 'eu-central-1' # Change this for different AWS region. Default is 'us-east-1'
      }
      config.fog_directory  = "webauto"
      config.cache_dir = "#{Rails.root}/tmp/uploads"   
end
