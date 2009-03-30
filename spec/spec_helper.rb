require File.dirname(__FILE__) + '/../lib/sinatra-clone'

begin
  require 'rackbox'
rescue LoadError => ex
  raise "To run the sinatra-clone specs, you need the rackbox gem: sudo gem install remi-rackbox"
end
