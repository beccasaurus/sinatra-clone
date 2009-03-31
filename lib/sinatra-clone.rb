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

    def add_route http_method, matcher, block
      if matcher.is_a? String
        named_captures = matcher.scan(/:(\w+)/)
        unless named_captures.empty?
          matcher = Regexp.new(matcher.gsub(/:(\w+)/, '(\w+)')) # replace :x with (\w+)
          # add a named_captures method to the Regexp object with the names of the captures
          eval "def matcher.named_captures
            #{ named_captures.map {|arr| arr.first }.inspect }
          end"
        end
      end
      routes[http_method][matcher] = block
    end

    def get path, &block
      add_route :get, path, block
    end

    def post path, &block
      add_route :post, path, block
    end
    
    def put path, &block
      add_route :put, path, block
    end
    
    def delete path, &block
      add_route :delete, path, block
    end

    def helpers &block
      responder_class.class_eval &block
    end

    def use middlware
      middlewares.unshift middlware
    end

    def call env
      # wrap up this application's logic in a mini rack app
      rack_app = lambda { |env|
        http_method = env['REQUEST_METHOD'].downcase.to_sym
        path        = env['PATH_INFO']

        params      = { }
        match       = nil

        matchers = routes[http_method]
        matchers.each do |matcher, block|
          match_data = matcher.match(path)
          if match_data
            params['captures'] = match_data[1..1_000_000]
            if matcher.respond_to? :named_captures
              matcher.named_captures.each_with_index do |key, index|
                params[key] = match_data[index + 1]
              end
            end
            match = block
          end
        end
        
        if match
          responder = responder_class.new env
          responder.params.merge! params
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
