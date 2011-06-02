require 'rack'

module Rack
  class CORS
    def initialize(app, options={})
      @app = app
      @options = {
        request_methods: ['OPTIONS'],
        max_age: '127800',
        any_origin: 'false',
        allowed_origins: []
      }.merge(options)
    end

    def call(env)
      cors_headers = {}
      if !env['Origin'].nil?
        return forbidden unless cors_ok(env['Origin'])
        cors_headers = basic_headers
      end
      if env['REQUEST_METHOD'] == 'OPTIONS'
        return forbidden unless method_ok(env['Access-Control-Request-Method'])
        return preflight_request(env)
      end
      status, headers, body = @app.call env
      [status, headers.merge(cors_headers), body]
    end

    def preflight_request(env)
      [200, preflight_headers, nil]
    end

    def preflight_headers
      {
        'Access-Control-Allow-Origin' => access_control_allow_origin,
        'Access-Control-Allow-Methods' => access_control_allow_methods,
        'Access-Control-Max-Age' => '127800'
      }
    end

    def basic_headers
      { 'Access-Control-Allow-Origin' => access_control_allow_origin }
    end

    def access_control_allow_origin
      @allowed_origins ||= allowed_origins
    end

    def access_control_allow_methods
      @allowed_methods ||= @options[:request_methods].join(',')
    end

    def allowed_origins
      if @options[:any_origin]
        '*'
      else
        @options[:allowed_origins].join(',')
      end
    end

    def cors_ok(origin)
      @options[:any_origin] || @options[:allowed_origins].include?(origin)
    end

    def method_ok(method)
      @options[:request_methods].include?(method)
    end

    def forbidden
      [403, {'Content-Type' => 'text/plain'}, []]
    end
  end
end
