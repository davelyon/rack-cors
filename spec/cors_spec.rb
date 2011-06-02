require 'spec_helper'
require 'rack_cors'

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
    it "are unchanged" do
      headers.should == plain_headers
    end
  end

  describe "a simple CORS request" do
    describe "headers" do
      subject { headers.keys }
      it { should include('Access-Control-Allow-Origin') }
      it { should include('Access-Control-Allow-Headers')}
      it { should include('Access-Control-Max-Age') }
      it { should include('Access-Control-Allow-Headers')}
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
      subject { headers.keys }
      it { should include('Access-Control-Allow-Origin') }
      it { should include('Access-Control-Allow-Headers')}
      it { should include('Access-Control-Max-Age') }
      it { should include('Access-Control-Allow-Headers')}
    end
  end

  context "with all options specified" do
    let(:options){ { allowed_origins: allowed_origins,
                     any_origin: false,
                     request_methods: ['OPTIONS','GET','POST'],
                     allowed_headers: ['X-Requested-With', 'X-Some-Header'] } }
    describe "Access-Controll-Allow-Origin header" do
      subject {headers['Access-Control-Allow-Origin'] }
      it { should == options[:allowed_origins].join(',') }
    end
    describe "Access-Control-Allow-Methods" do
      subject { headers['Access-Control-Allow-Methods']} 
      it { should == options[:request_methods].join(',') }
    end
    describe "Access-Control-Allow-Headers" do
      subject { headers['Access-Control-Allow-Headers'] }
      it { should == options[:allowed_headers].join(',') }
    end
  end
end
