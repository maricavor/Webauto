class Sleeper
  @queue = :sleep

  def self.perform(seconds)
  	Vehicle.lalala
    sleep(seconds)
  end
end