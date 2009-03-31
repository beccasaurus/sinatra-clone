require File.dirname(__FILE__) + '/spec_helper'

describe SinatraClone::Application, 'basic functionality' do
  
  it 'should be a valid Rack application' do
    app {
      get('/'){ 'hello from SinatraClone rack app!' }
    }.should respond_to(:call)
  end

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

  it 'should be able to #get' do
    app { get('/'){ 'hello from GET' } }

    request('/').body.should == 'hello from GET'
  end

  it 'should be able to #post' do
    app { post('/'){ 'hello from POST' } }

    request('/', :method => :post).body.should == 'hello from POST'
  end

  it 'should be able to #put' do
    app { put('/'){ 'hello from PUT' } }

    request('/', :method => :put).body.should == 'hello from PUT'
  end

  it 'should be able to #delete' do
    app { delete('/'){ 'hello from DELETE' } }

    request('/', :method => :delete).body.should == 'hello from DELETE'
  end

end
