module Rack::CORS
  class Handler
    def initialize(app, options={})
      @app = app
      @options = {
        request_methods: ['OPTIONS'],
        max_age: '86400',
        any_origin: false,
        allowed_origins: [],
        allowed_headers: [] }.merge(options)
    end

    def call(env)
      if env['REQUEST_METHOD'] == 'OPTIONS' && env['HTTP_ORIGIN']
        return preflight_request(env)
      end
      status, headers, body = @app.call env
      [status, headers.merge(base_headers), body]
    end

    def preflight_request(env)
      [200, preflight_headers, []]
    end

    def base_headers
      { 'Access-Control-Allow-Origin' => allowed_origins,
        'Access-Control-Allow-Methods' => @options[:request_methods].join(' '),
        'Access-Control-Max-Age' => @options[:max_age],
        'Access-Control-Allow-Headers' => @options[:allowed_headers].join(' ') }
    end

    def preflight_headers
      base_headers.merge( { 'Content-Length' => 0 })
    end

    def allowed_origins
      @options[:any_origin] ? '*' : @options[:allowed_origins].join(' ')
    end
  end
end
