require File.dirname(__FILE__) + '/spec_helper'

describe SinatraClone, 'basic functionality' do

  it 'should be able to access #request object' do
    app = SinatraClone.app do
      get '/foo' do
        request.env.inspect
      end
    end
    RackBox.request(app, '/foo').body.should include('"PATH_INFO"=>"/foo"')
  end

  it 'should be able to create and access helper methods' do
    app = SinatraClone.app do
      helpers do
        def a_helper str
          "called a_helper with: #{ str }"
        end
      end

      get '/' do
        a_helper('foo') 
      end
    end
    RackBox.request(app, '/').body.should == "called a_helper with: foo"
  end

  it 'should be able to access #params' do
    app = SinatraClone.app do
      get '/' do
        params.inspect
      end
    end
    RackBox.request(app, '/', :params => { :chunky => 'bacon' }, :method => :get).body.
      should include('"chunky"=>"bacon"')
  end

  it 'should be able to access #response object' do
    app = SinatraClone.app do
      get '/' do
        response['Content-Type'] = 'application/testing'
        "hello"
      end
    end
    RackBox.request(app, '/').headers['Content-Type'].should == 'application/testing'
  end

  it 'should be able to create routes with #params, eg. /foo/:id'

  it 'should be able to #put in a SinatraClone application'
  it 'should be able to #post in a SinatraClone application'
  it 'should be able to #delete in a SinatraClone application'

  it 'should be able to test a simple SinatraClone application' do
    app = SinatraClone.app do
      get '/' do
        "hello from my first sinatra-clone application!"
      end
    end
    RackBox.request(app, '/').body.should == "hello from my first sinatra-clone application!"
  end
  
  it 'should be able to test *another* simple SinatraClone application' do
    app = SinatraClone.app do
      get '/' do
        "hello from *another* SinatraClone application"
      end
    end
    RackBox.request(app, '/').body.should == "hello from *another* SinatraClone application"
  end

  it "should tell me when the requested route isn't found" do
    app = SinatraClone.app do
      get '/' do
        "hi from root"
      end
    end
    RackBox.request(app, '/').body.should == "hi from root"
    RackBox.request(app, '/foo').body.should include('Route not found')
  end

end
