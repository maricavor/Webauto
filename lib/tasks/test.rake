namespace :railsapp do
  desc "Run minutely report"
    task :minutely_report => :environment do
    month = Time.now.month
    Rails.logger.info "Generate rake report..."
    vehicle=Vehicle.find(:first)
    Rails.logger.info vehicle.lalala(month)
  end
end