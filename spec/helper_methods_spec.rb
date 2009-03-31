require File.dirname(__FILE__) + '/spec_helper'

describe SinatraClone::Application, 'helper methods' do

  it 'should have access to a #request object' do
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

  it 'should be able to easily #redirect' do
    app {
      get('/'){ redirect '/login' }
    }

    request('/').status.should == 302
    request('/').headers['Location'].should == '/login'
  end

  it 'should be able to easily set #status code of response' do
    app {
      get '/' do
        status 404
        "Not Found!"
      end
    }

    request('/').body.should == 'Not Found!'
    request('/').status.should == 404
  end

end
