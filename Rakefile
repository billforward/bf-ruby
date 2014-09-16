require "bundler/gem_tasks"

begin
	require 'rspec/core/rake_task'

	RSpec::Core::RakeTask.new(:spec) do |t|
		# t.pattern = 'spec/*_spec.rb'
		spec_files = FileList['spec/*_spec.rb']
		# trick t.pattern into accepting a list of files (otherwise deprecated)
		# otherwise globbing does not work on Windows (only first file is matched)
		t.pattern = spec_files
		# default pattern is:
		# spec/\*\*\{,/\*/\*\*\}/\*_spec.rb
		# "spec/**/*_spec.rb"

		t.rspec_opts = "--color --format documentation"
	end

	# Make 'Rspec test run' the default task
	task :default => :spec
rescue LoadError
	# no rspec available
end
