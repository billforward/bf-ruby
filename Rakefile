require "bundler/gem_tasks"

begin
	require 'rspec/core/rake_task'

	RSpec::Core::RakeTask.new(:spec) do |t|
		# these specs test syntax and language features
		syntax_specs = FileList['spec/syntax/*_spec.rb']
		# these specs use mocking to test entities without calling a real API
		component_specs = FileList['spec/component/*_spec.rb']

		spec_files = FileList[]
		spec_files.concat(syntax_specs)
		spec_files.concat(component_specs)

		# trick t.pattern into accepting a list of files (otherwise deprecated)
		# otherwise globbing does not work on Windows (only first file is matched)
		t.pattern = spec_files

		t.rspec_opts = "--color --format documentation"
	end

	# Make 'Rspec test run' the default task
	task :default => :spec
rescue LoadError
	# no rspec available
end
