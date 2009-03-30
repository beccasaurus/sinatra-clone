require File.dirname(__FILE__) + '/spec_helper'

describe SinatraClone, 'basic functionality' do
  
  it 'SinatraClone.app {} should return a valid Rack application' do
    app = SinatraClone.app do
      get '/' do
        "hello from SinatraClone rack app!"
      end
    end
    app.should respond_to(:call)
  end

  it 'should be able to test a simple SinatraClone app' do
    app = SinatraClone.app do
      get '/' do
        "hello from first app!"
      end
    end
    RackBox.request(app, '/').body.should == "hello from first app!"
  end

  it 'should be able to test *another* simple SinatraClone app' do
    app = SinatraClone.app do
      get '/' do
        "hello from *another* app!"
      end
    end
    RackBox.request(app, '/').body.should == "hello from *another* app!"
  end

  it 'should have access to a request object' do
    RackBox.request(SinatraClone.app do
      get '/foo' do
        request.env.inspect
      end
    end, '/foo').body.should include('"PATH_INFO"=>"/foo"') 
  end

  it 'should be able to add helper methods' do
    RackBox.request(SinatraClone.app do
      helpers do
        def a_helper str
          "string passed to helper: #{ str }"
        end
      end

      get '/' do
        a_helper("foo")
      end
    end, '/').body.should == "string passed to helper: foo" 
  end

end
