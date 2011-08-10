require 'spec_helper'
require 'rack/cors'

shared_examples_for "CORS Request" do
  subject { headers.keys }
  it { should include('Access-Control-Allow-Origin') }
  it { should include('Access-Control-Allow-Headers')}
  it { should include('Access-Control-Max-Age') }
  it { should include('Access-Control-Allow-Headers')}
end

describe "Rack::CORS" do
  let(:plain_headers) { {'Content-Type' => 'text/plain'} }
  let(:app) { lambda { |env| [200, plain_headers, ['CORS is Cool']] } }
  let(:allowed_origins) { ['http://example.com','http://cors.st','http://a.b']}
  let(:env) { Rack::MockRequest.env_for '/', request_options }
  let(:cors){ Rack::CORS.new app, options}
  let(:request) { cors.call env }
  let(:status) { request[0] }
  let(:headers) { request[1] }
  let(:body) { request[2] }
  let(:request_options) { {'HTTP_ORIGIN' => 'http://example.com'} }
  let(:options) { {request_methods: ['OPTIONS','GET','POST'], any_origin: true} }

  describe "non-cors requests" do
    let(:request_options) {{}}
    it_should_behave_like "CORS Request"
  end

  describe "a simple CORS request" do
    describe "headers" do
      it_should_behave_like "CORS Request"
    end
  end

  describe "non-cors OPTIONS request" do
    let(:request_options) {
      {'REQUEST_METHOD' => 'OPTIONS'}
    }
    it_should_behave_like "CORS Request"
    it "should not have preflight headers" do
      headers['Content-Length'].should_not == 0
    end
  end

  describe "pre-flight request" do
    let(:request_options) {
      {'REQUEST_METHOD' => 'OPTIONS',
       'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'POST', 
       'HTTP_ORIGIN' => 'http://example.com'}
    }
    it "be an empty response" do
      body.should be_empty
    end
    it "Content-Length should be 0" do
      headers['Content-Length'].should == 0
    end
    describe "headers" do
      it_should_behave_like "CORS Request"
    end
  end

  context "with all options specified" do
    let(:options){ { allowed_origins: allowed_origins,
                     any_origin: false,
                     max_age: '0',
                     request_methods: ['OPTIONS','GET','POST'],
                     allowed_headers: ['X-Requested-With', 'X-Some-Header'] } }
    describe "Access-Controll-Allow-Origin header" do
      subject {headers['Access-Control-Allow-Origin'] }
      it { should == 'http://example.com http://cors.st http://a.b'}
    end
    describe "Access-Control-Allow-Methods" do
      subject { headers['Access-Control-Allow-Methods']} 
      it { should == 'OPTIONS GET POST' }
    end
    describe "Access-Control-Allow-Headers" do
      subject { headers['Access-Control-Allow-Headers'] }
      it { should == 'X-Requested-With X-Some-Header'}
    end
    describe "Access-Control-Max-Age" do
      subject { headers['Access-Control-Max-Age'] }
      it { should == options[:max_age] }
    end
  end

  describe "passes Rack::Lint" do
    let(:lint) { Rack::Lint.new( cors ) }
    subject { lint.call(env) }
    it { should be_true }
  end
end
