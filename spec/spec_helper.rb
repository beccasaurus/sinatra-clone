require File.dirname(__FILE__) + '/../lib/sinatra-clone'

begin
  require 'rackbox'
rescue LoadError => ex
  raise "To run the sinatra-clone specs, you need the rackbox gem: sudo gem install remi-rackbox"
end

module SinatraCloneSpecHelpers
  def app &block
    @app = SinatraClone.app &block
  end

  def request *args
    options = args.pop if args.last.is_a? Hash
    app     = args.shift if args.first.respond_to? :call
    path    = args.shift
    app     ||= @app
    options ||= {}
    RackBox.request app, path, options
  end
end

Spec::Runner.configure do |config|
  config.include SinatraCloneSpecHelpers
end
