require "bundler/gem_tasks"

begin
	require 'rspec/core/rake_task'

	RSpec::Core::RakeTask.new(:spec) do |t|
		t.pattern = 'spec/*_spec.rb'
		# default pattern is:
		# spec/\*\*\{,/\*/\*\*\}/\*_spec.rb
	end

	# Make 'Rspec test run' the default task
	task :default => :spec
rescue LoadError
	# no rspec available
end
