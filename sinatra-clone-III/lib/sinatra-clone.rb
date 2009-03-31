$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'rack'

class SinatraClone
  class << self
    
    # returns a SinatraClone::Application
    def app &block
      SinatraClone::Application.new(&block)
    end

  end
end

class SinatraClone #:nodoc:

  # represents a unique SinatraClone application
  #
  # this is the scope where the application gets evaluates, eg.
  #
  #   #get
  #   #put
  #
  #   #helpers
  #
  #   ... etc
  #
  class Application

    # Hash of Routes, eg. { :get => { '/' => <proc>, '/foo' => <proc> } }
    attr_accessor :routes

    def initialize &block
      @routes = { :get => { } }
      instance_eval &block
    end

    def get path, &block
      routes[:get][path] = block
    end

    def helpers &block
      Responder.class_eval &block # TODO each application should have its own Responder
      # if we have multiple SinatraClone apps loaded in the same process
      # then Responder will have *all* of the helpers, etc ...
    end

    def call env
      @request = Rack::Request.new env
      http_method = env['REQUEST_METHOD'].downcase.to_sym
      path        = env['PATH_INFO']
      match       = routes[http_method][path]
      if match
        responder = Responder.new env
        body = responder.instance_eval &match
        responder.finish body
      else
        [ 200, {}, "Route not found: #{http_method} #{path}" ]
      end
    end

  end

  # this is the scope in which blocks (eg. get('/'){ .*. }) get evaluates
  class Responder
    attr_reader :request, :response

    def params
      request.params
    end

    def initialize env
      @request  = Rack::Request.new env
      @response = Rack::Response.new
    end

    def finish body
      response.write body
      response.finish
    end
  end

end
