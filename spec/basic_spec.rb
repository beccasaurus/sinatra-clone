require File.dirname(__FILE__) + '/spec_helper'

describe SinatraClone, 'basic functionality' do
  
  it 'SinatraClone#app should return a valid Rack application' do
    app {
      get('/'){ 'hello from SinatraClone rack app!' }
    }.should respond_to(:call)
  end

  it 'should be able to #get'
  it 'should be able to #put'
  it 'should be able to #post'
  it 'should be able to #delete'

  it 'should be able to test a simple SinatraClone app' do
    app do
      get('/'){ "hello from first app!" }
    end

    request('/').body.should == "hello from first app!"
  end

  it 'should be able to test *another* simple SinatraClone app' do
    app do
      get('/'){ "hello from *another* app!" }
    end

    request('/').body.should == "hello from *another* app!"
  end

  it 'should have access to a request object' do
    app do
      get('/foo'){ request.env.inspect }
    end

    request('/foo').body.should include('"PATH_INFO"=>"/foo"') 
  end

  it 'should be able to add helper methods' do
    app do
      helpers do
        def a_helper str
          "string passed to helper: #{ str }"
        end
      end

      get '/' do
        a_helper("foo")
      end
    end
    
    request('/').body.should == "string passed to helper: foo" 
  end

  it 'applications should have their own unique helper methods'

  it 'should be able to access #response object' do
    app do
      get '/' do
        response['Content-Type'] = 'application/testing'
        "hello"
      end
    end

    request('/').headers['Content-Type'].should == 'application/testing'
  end

  it 'should be able to access #params' do
    app {
      get('/'){ params.inspect }
    }

    request('/', :method => :get, :params => { :chunky => 'bacon' }).body.
      should include('"chunky"=>"bacon"')
  end

  it "should tell me when the requested route isn't found" do
    pending
    app = SinatraClone.app do
      get '/' do
        "hi from root"
      end
    end
    RackBox.request(app, '/').body.should == "hi from root"
    RackBox.request(app, '/foo').body.should include('Route not found')
  end

  it 'should be able to create routes with #params, eg. /foo/:id'

end
