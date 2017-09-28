#init
#comment this for reindex in production (use RAILS_ENV=development in production)
# uncomment for localhost 
#if Rails.env.production?

Sunspot.config.solr.url = 'http://solradmin:maricavor@localhost:8983/solr'
#end
#####################