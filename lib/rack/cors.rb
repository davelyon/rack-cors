require 'rack'
require 'rack/cors/handler'
require 'rack/cors/headers'

module Rack::CORS
  def self.new(app, options)
    Handler.new(app, options)
  end
end
