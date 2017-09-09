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
if Rails.env.development? || Rails.env.test?
Resque.redis = Redis.new(config[Rails.env])
end
if Rails.env.production?
Resque.redis = Redis.new(:host => 127.0.0.1, :port => 6379, :password => maricavorredis001, :thread_safe => true)
end
Resque.schedule = schedule
Resque.redis.namespace = "<a href='http://www.webauto.ee' style= 'text-decoration:none;color:#cccccc;'>Webauto</a>"