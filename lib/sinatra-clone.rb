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

  # instance methods in here are available globally 
  # to an application, eg:
  #
  #   get '/' ...
  #
  #   helpers do ...
  #
  # for the methods that are available within the 
  # route blocks (eg. #get) see Responder
  #
  class Application

    # most or all of these should probably be private
    attr_reader :routes, :responder_class, :middlewares

    def initialize &block
      set_defaults
      instance_eval &block  
    end

    def get path, &block
      routes[:get][path] = block
    end

    def post path, &block
      routes[:post][path] = block
    end
    
    def put path, &block
      routes[:put][path] = block
    end
    
    def delete path, &block
      routes[:delete][path] = block
    end

    def helpers &block
      responder_class.class_eval &block
    end

    def use middlware
      middlewares << middlware
    end

    def call env
      # wrap up this application's logic in a mini rack app
      rack_app = lambda { |env|
        match = routes[ env['REQUEST_METHOD'].downcase.to_sym ][ env['PATH_INFO'] ]
        if match
          responder = responder_class.new env
          body = responder.instance_eval &match
          responder.finish(body)
        else
          [ 200, {}, "Route not found!  All Routes: #{ routes.inspect }" ]
        end
      }

      # setup middlewares
      middlewares.each do |middleware|
        rack_app = middleware.new rack_app
      end

      # call middlewares (with this app's logic being the most inner app)
      rack_app.call env
    end

    private

    def set_defaults
      @routes          ||= { :get => {}, :post => {}, :put => {}, :delete => {} }
      @responder_class ||= Responder.dup
      @middlewares     ||= []
    end

    # This is basically the scope in which blocks (eg. get('/'){...}) get evaluated
    #
    # it should be specific to a given Application
    #
    class Responder
      attr_reader :request, :response

      def params
        request.params
      end

      def redirect path
        response['Location'] = path
        response.status = 302
      end

      def status code
        response.status = code
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
end
