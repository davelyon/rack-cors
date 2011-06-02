require 'spec_helper'
require 'rack-cors'

describe Rack::CORS do
  let(:plain_headers) { {'Content-Type' => 'text/plain'} }
  let(:app) { lambda { |env| [200, plain_headers, ['CORS is Cool']] } }
  let(:env) { Rack::MockRequest.env_for '/', request_options }
  let(:cors){ Rack::CORS.new app, options}
  let(:request) { cors.call env }
  let(:status) { request[0] }
  let(:headers) { request[1] }
  let(:body) { request[2] }
  context "with allowed origins specified" do
    let(:options){
      { allowed_origins: ['http://example.com', 'http://cors.site' ],
        any_origin: false
      }
    }
    context "from correct origin" do
      let(:request_options) { {'Origin' => 'http://example.com'} }
      it "responds with the correct origins" do
        headers['Access-Control-Allow-Origin'].should ==
          options[:allowed_origins].join(',')
      end
    end
    context "from incorrect origin" do
      let(:request_options) { {'Origin' => 'http://wrong.com'} }
      it "forbids requests" do
        status.should == 403
      end
    end
  end
  context "any origin" do
    let(:options) {
      {
      request_methods: ['OPTIONS','GET', 'POST'],
      any_origin: true
      }
    }
    context "non-cors requests" do
      let(:request_options) {{}}
      it "do not change the request" do
        headers.should == plain_headers
      end
    end
    context "when simple CORS request" do
      let(:request_options) { {'Origin' => 'http://cors-site.com'} }
      it "injects the Access-Control-Allow-Origin header" do
        headers.keys.should include('Access-Control-Allow-Origin')
        headers['Access-Control-Allow-Origin'].should == '*'
      end
    end
    context "when pre-flighting required" do
      let(:request_options) { 
        {'REQUEST_METHOD' => 'OPTIONS', 'Access-Control-Request-Method' => 'POST'}
      }
      context "valid request" do
        it "responds to OPTIONS" do
          status.should == 200
        end
        it "responds with the proper headers" do
          status, headers, body = cors.call env
          headers.keys.should include('Access-Control-Allow-Origin')
          headers.keys.should include('Access-Control-Allow-Methods')
          headers.keys.should include('Access-Control-Max-Age')
          body.should == nil
        end
      end
    end
    context "next request after pre-flighting" do
      let(:request_options) { {'Origin' => 'http://cors-site.com'} }
      it "includes required headers" do
        headers['Access-Control-Allow-Origin'].should == '*'
      end
    end
  end
  context "with request methods specified" do
    let(:options) {
      {request_methods: ['OPTIONS','POST'], any_origin: true}
    }
    context "valid request" do
    let(:request_options) {
      {'Origin' => 'http://cors-site.com',
       'REQUEST_METHOD' => 'OPTIONS',
       'Access-Control-Request-Method' => 'POST'}
    }
      it "responds with the correct headers" do
        headers['Access-Control-Allow-Methods'].should ==
          options[:request_methods].join(',')
      end
    end
    context "with incorrect type" do
    let(:request_options) {
      {'Origin' => 'http://cors-site.com',
       'REQUEST_METHOD' => 'OPTIONS',
       'Access-Control-Request-Method' => 'GET'}
    }
      it "forbids requests" do
        status.should == 403
      end
    end
  end
end
