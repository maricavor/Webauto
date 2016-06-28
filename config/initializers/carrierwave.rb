CarrierWave.configure do |config|
    config.storage = :fog
    #config.enable_processing = true
    #config.root = ENV['OPENSHIFT_DATA_DIR']
    #config.cache_dir = config.root + 'uploads'
    config.fog_credentials = {
          :provider               => 'AWS',
          :aws_access_key_id      => "AKIAIVRLUKEBKRXEDCMQ",
          :aws_secret_access_key  => "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",
          :region                 => 'eu-central-1' # Change this for different AWS region. Default is 'us-east-1'
      }
      config.fog_directory  = "webauto"
      config.cache_dir = "#{Rails.root}/tmp/uploads"   
end