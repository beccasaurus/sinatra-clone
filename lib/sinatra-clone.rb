$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'rack'

class SinatraClone
  class << self
    
    # returns a SinatraClone app, per what's defined in the passed &block
    #
    # for example, a rackup file could look like this:
    #
    #   require 'sinatra-clone'
    #   run SinatraClone.app do
    #     
    #     get '/' do
    #       "hello from my app"
    #     end
    #
    #   end
    #
    def app &block
      SinatraClone::Application.new(&block)
    end

  end
end

class SinatraClone #:nodoc:
  class Application

    attr_accessor :routes

    def initialize &block
      set_defaults
      instance_eval &block  
    end

    def get path, &block
      routes[:get][path] = block
    end

    def call env
      match = routes[ env['REQUEST_METHOD'].downcase.to_sym ][ env['PATH_INFO'] ]
      if match
        [ 200, {}, self.instance_eval(&match) ]
      else
        [ 200, {}, "Route not found!  All Routes: #{ routes.inspect }" ]
      end
    end

    private

    def set_defaults
      @routes ||= { :get => {} }
    end
  end
end
