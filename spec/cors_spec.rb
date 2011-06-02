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
    it "succeeds" do
      status.should == 200
    end
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
    it "responds to OPTIONS" do
      status.should == 200
    end
    describe "headers" do
      subject { headers.keys }
      it { should include('Access-Control-Allow-Origin') }
      it { should include('Access-Control-Allow-Headers')}
      it { should include('Access-Control-Max-Age') }
      it { should include('Access-Control-Allow-Headers')}
    end
    context "next request after pre-flighting" do
      describe "headers" do
        subject { headers.keys }
        it { should include('Access-Control-Allow-Origin') }
        it { should include('Access-Control-Allow-Headers')}
        it { should include('Access-Control-Max-Age') }
        it { should include('Access-Control-Allow-Headers')}
      end
    end
  end

  context "when allowed origins specified" do
    let(:options){ { allowed_origins: allowed_origins,
                     any_origin: false,
                     request_methods: ['OPTIONS','GET','POST'] } }
    context "from correct origin" do
      it "succeeds" do
        status.should == 200
      end
      describe "Access-Controll-Allow-Origin header" do
        subject {headers['Access-Control-Allow-Origin'] }
          it { should == options[:allowed_origins].join(',') }
      end
    end
    context "from incorrect origin" do
      let(:request_options) { {'HTTP_ORIGIN' => 'http://wrong.com'} }
      it "is forbidden" do
        status.should == 403
      end
    end
  end

  context "with request methods specified" do
    context "valid request" do
      let(:request_options) {
        {'HTTP_ORIGIN' => 'http://cors-site.com',
         'REQUEST_METHOD' => 'OPTIONS',
         'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'POST'}
      }
      describe "Access-Control-Allow-Methods" do
        subject { headers['Access-Control-Allow-Methods']} 
        it { should == options[:request_methods].join(',') }
      end
    end
    context "with invalid request method" do
      let(:request_options) {
        {'HTTP_ORIGIN' => 'http://cors-site.com',
         'REQUEST_METHOD' => 'OPTIONS',
         'HTTP_ACCESS_CONTROL_REQUEST_METHOD' => 'PUT'}
      }
      it "is forbidden" do
        status.should == 403
      end
    end
  end

  context "with allowed headers specified" do
    let(:options) {
      {any_origin: true,
       request_methods: ['OPTIONS', 'GET'],
       allowed_headers: ['X-Requested-With', 'X-Some-Header'] } }
    describe "Access-Control-Allow-Headers" do
      subject { headers['Access-Control-Allow-Headers'] }
      it { should == options[:allowed_headers].join(',') }
    end
  end
end
