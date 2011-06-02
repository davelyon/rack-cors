require 'rack/cors/headers'
module Rack::CORS
  class Handler
    def initialize(app, options={})
      @app = app
      @options = {
        request_methods: ['OPTIONS'],
        max_age: '127800',
        any_origin: false,
        allowed_origins: [],
        allowed_headers: []
      }.merge(options)
    end

    def call(env)
      cors_headers = {}
      if env.has_key? 'HTTP_ORIGIN'
        return forbidden unless valid?(env)
        if env['REQUEST_METHOD'] == 'OPTIONS'
          return preflight_request(env)
        end
        cors_headers = preflight_headers
      end
      status, headers, body = @app.call env
      [status, headers.merge(cors_headers), body]
    end

    def valid?(request)
      allow_origin(request['HTTP_ORIGIN']) &&
        allow_method(request['REQUEST_METHOD'])
    end

    def preflight_request(env)
      return forbidden unless allow_method(env['HTTP_ACCESS_CONTROL_REQUEST_METHOD'])
      [200, preflight_headers, []]
    end

    def forbidden
      [403, {'Content-Type' => 'text/plain'}, []]
    end

    def allow_origin(origin)
      @options[:any_origin] || @options[:allowed_origins].include?(origin)
    end

    def allow_method(method)
      @options[:request_methods].include?(method)
    end

    def preflight_headers
      {
        'Access-Control-Allow-Origin' => allowed_origins,
        'Access-Control-Allow-Methods' => @options[:request_methods].join(','),
        'Access-Control-Max-Age' => @options[:max_age],
        'Access-Control-Allow-Headers' => @options[:allowed_headers].join(',')
      }
    end

    def allowed_origins
      @options[:any_origin] ? '*' : @options[:allowed_origins].join(',')
    end
  end
end
