require 'rake'
require 'rspec/core/rake_task'
task :spec do
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w{--colour --format progress}
    t.pattern = 'spec/cors/*_spec.rb'
  end
end
