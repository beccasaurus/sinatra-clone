require File.dirname(__FILE__) + '/spec_helper'

describe SinatraClone::Application, 'middleware' do

  class ExampleMiddleware
    def initialize app
      @app = app
    end
    def call env
      status, headers, each_able = @app.call env
      body = ''
      each_able.each {|string| body << string }
      [ 200, {}, "hello from middleware ... inner app body: #{ body }" ]
    end
  end

  it 'should be able to #use Rack middleware' do
    app do
      use ExampleMiddleware

      get('/'){ "FOO" }
    end

    request('/').body.should == "hello from middleware ... inner app body: FOO"
  end

end
