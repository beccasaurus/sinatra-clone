require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/example_middleware'

describe SinatraClone::Application, 'middleware' do

  it 'should be able to #use Rack middleware' do
    app do
      use ExampleMiddleware

      get('/'){ "FOO" }
    end

    request('/').body.should == "hello from middleware ... inner app body: FOO"
  end

  it 'should call middleware in the right order' do
    app do
      use UpdateBodyWith1
      use UpdateBodyWith2

      get('/'){ "FOO" }
    end

    request('/').body.should == "12FOO"
  end

end
