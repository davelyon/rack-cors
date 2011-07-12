lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rack/cors/version'

Gem::Specification.new do |s|
  s.version = UseTheCors::VERSION
  s.platform = Gem::Platform::RUBY

  s.name = "use_the_cors"
  s.summary = %Q{Rack middleware to enable Cross-Origin Request Sharing (CORS)}
  s.description = %Q{Enables basic and preflight CORS requests for any application that can use Rack middleware.}
  s.email = 'dave@davelyon.net'
  s.authors = 'Dave Lyon'
  s.date     = '2011-07-07'

  s.extra_rdoc_files = ["README.rdoc"]
  s.files = Dir.glob("lib/**/*") + %w(README.rdoc)

  s.require_path = 'lib'
  s.required_rubygems_version = ">= 1.3.6"
  s.add_development_dependency "rspec", "~> 2.6.0"
  s.add_dependency "rack", ">= 1.2.0"

  s.test_files = Dir.glob("spec/**/*_spec.rb") + %w{spec/spec_helper.rb}
end
