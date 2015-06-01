
class CronTask

  class << self

    def perform(method)
      with_logging method do
        self.new.send(method)
      end
    end

    def with_logging(method, &block)
      log("starting...", method)

      time = Benchmark.ms do
        yield block
      end

      log("completed in (%.1fms)" % [time], method)
    end

    def log(message, method = nil)
      now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      Rails.logger.info "#{now} %s#%s - #{message}" % [self.name, method]
    end

  end
  
  def immediate_alert
    notify("Immediately")
  end
 def daily_alert
    notify("Alert") #was notify(u,"Daily")
  end
   def weekly_alert
    notify("Weekly")
  end
   def monthly_alert
    notify("Monthly")
  end
  def calculate
    Vehicle.lalala
    sleep(5)
  end

 def notify_old(user,freq)
 _new_adverts=[]
  _searches=user.saved_searches.where(:alert_freq => freq)
    #print _searches
    _searches.each do |s|
    s.run.results.each do |vehicle|
      a_id=vehicle.advert_id
        unless SearchAlert.exists?(:advert_id => a_id, :search_id => s.id)
          _new_adverts << vehicle.advert
          alert=SearchAlert.new
          alert.advert_id=a_id
          alert.search_id=s.id
          alert.save!
        end
      end
      if _new_adverts.size>0
        Notifier.adverts_created(_new_adverts, s).deliver
      end
    end
 end
 def notify(freq)
   _searches=Search.where("name IS NOT NULL").where(:alert_freq=>freq)
      Rails.logger.info _searches.map {|s| s.name }.join(',')
    _searches.each do |s|
      Rails.logger.info "Checking saved search "+s.name+" for user "+s.user.email
      Rails.logger.info "Adverts: "+s.adverts
      _current_adverts=s.run("background").results.map {|v| v.advert_id }.join(',') 
      Rails.logger.info "Found adverts: "+_current_adverts
       new_adverts=_current_adverts.split(',')-s.adverts.split(',')
      Rails.logger.info "New adverts: "+new_adverts.join(',')
      if new_adverts.size>0
        Notifier.adverts_created(new_adverts, s).deliver
      end
 end
end
end