#init
#uncomment this before deploy!!!
#if Rails.env.production?
#Sunspot.config.solr.url = 'http://maricavor:phoenix32@solr-webauto.rhcloud.com/solr'
Sunspot.config.solr.url = 'http://solradmin:maricavor@localhost:8983/solr'
#end
#####################