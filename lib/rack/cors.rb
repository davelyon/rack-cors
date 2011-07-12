require 'rack'
require 'rack/cors/handler'

module Rack::CORS
  def self.new(app, options={})
    Handler.new(app, options)
  end
end
