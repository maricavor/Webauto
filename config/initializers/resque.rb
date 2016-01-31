Dir[File.join(Rails.root, 'app', 'jobs', '*.rb')].each { |file| require file }
require 'resque'
require 'resque-scheduler'
require 'resque/scheduler/server'
#config = YAML.load_file("#{Rails.root}/config/redis.yml") 
schedule = YAML.load_file("#{Rails.root}/config/rescue_schedule.yml")
config_template = ERB.new File.new("#{Rails.root}/config/redis.yml.erb").read
config = YAML.load config_template.result(binding)

Resque.logger = MonoLogger.new(File.open("#{Rails.root}/log/resque.log", "w+"))
Resque.logger.formatter = Resque::VeryVerboseFormatter.new
#uncomment this before deploy!!!
#Resque.redis = Redis.new(config[Rails.env])
Resque.redis = Redis.new(:host => ENV['OPENSHIFT_REDIS_HOST'], :port => ENV['OPENSHIFT_REDIS_PORT'], :password => ENV['REDIS_PASSWORD'], :thread_safe => true)
Resque.schedule = schedule
Resque.redis.namespace = "<a href='http://localhost:3000' style= 'text-decoration:none;color:#cccccc;'>Webauto</a>"