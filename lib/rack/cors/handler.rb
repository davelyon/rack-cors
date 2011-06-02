require 'rack/cors/headers'
module Rack::CORS
  class Handler
    include Headers
    def initialize(app, options={})
      @app = app
      @options = {
        request_methods: ['OPTIONS'],
        max_age: '127800',
        any_origin: 'false',
        allowed_origins: [],
        allowed_headers: []
      }.merge(options)
    end

    def call(env)
      cors_headers = {}
      if !env['Origin'].nil?
        return forbidden unless allow_origin(env['Origin'])
        cors_headers = basic_headers
      end
      if env['REQUEST_METHOD'] == 'OPTIONS'
        return forbidden unless allow_method(env['Access-Control-Request-Method'])
        return preflight_request(env)
      end
      status, headers, body = @app.call env
      [status, headers.merge(cors_headers), body]
    end

    def preflight_request(env)
      [200, preflight_headers, nil]
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

  end
end
