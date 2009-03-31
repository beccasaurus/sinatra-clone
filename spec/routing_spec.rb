require File.dirname(__FILE__) + '/spec_helper'

describe SinatraClone::Application, 'routing' do

  it "should tell me when the requested route isn't found" do
    app do
      get('/'){ "hi from root" }
    end
    
    request('/').body.should == "hi from root"
    request('/foo').body.should include('Route not found')
  end

  it 'should be able to create routes with #params, eg. /foo/:id' do
    pending
    app do
      get '/dogs/:id' do
        "dog ID is #{ params['id'] }"
      end
    end

    request('/dogs/5').body.should == "dog ID is 5"
  end

  it 'should be able to create routes from regular expressions (params[:captures])' do
    app do
      get /^\/dogs\/(\w+)$/ do
        "dog ID is #{ params['captures'].first }"
      end
    end

    request('/dogs/5').body.should == "dog ID is 5"
  end

end
