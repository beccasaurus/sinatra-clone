require File.dirname(__FILE__) + '/spec_helper'

describe SinatraClone::Application, 'routing' do

  it "should tell me when the requested route isn't found" do
    app do
      get('/'){ "hi from root" }
    end
    
    request('/').body.should == "hi from root"
    request('/foo').body.should include('Route not found')
  end

  it 'should be able to create routes with #params, eg. /foo/:id'
  it 'should be able to craete routes from regular expressions'

end
