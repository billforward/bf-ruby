require "bundler/gem_tasks"

begin
	require 'rspec/core/rake_task'

	# these specs test syntax and language features
	syntax_specs = FileList['spec/syntax/*_spec.rb']
	# these specs use mocking to test entities without calling a real API
	component_specs = FileList['spec/component/*_spec.rb']
	# these specs call the API, but in a read-only manner
	functional_good_citizen_specs = FileList['spec/functional/*_spec.rb']
	# these specs call the API, leaving lasting side-effects
	functional_bad_citizen_specs = FileList['spec/functional/bad_citizen/*_spec.rb']
	# these specs call the API, and also require prior setup (for example, ensure an invoice exists beforehand)
	# we do not consider these part of the main run, as they're particularly bad citizens
	functional_situational_specs = FileList['spec/functional/bad_citizen/situational/*_spec.rb']

	# offline tests
	fast_specs = FileList[]
	fast_specs.concat(syntax_specs)
	fast_specs.concat(component_specs)

	# offline tests + main functional run
	main_specs = FileList[]
	main_specs.concat(fast_specs)
	puts functional_good_citizen_specs
	main_specs.concat(functional_good_citizen_specs)
	main_specs.concat(functional_bad_citizen_specs)

	# offline tests + main functional run + situational functional
	all_specs = FileList[]
	all_specs.concat(main_specs)
	all_specs.concat(functional_situational_specs)
	

	RSpec::Core::RakeTask.new(:spec_offline) do |t|
		spec_files = FileList[]
		spec_files.concat(fast_specs)

		# trick t.pattern into accepting a list of files (otherwise deprecated)
		# otherwise globbing does not work on Windows (only first file is matched)
		t.pattern = spec_files

		t.rspec_opts = "--color --format documentation"
	end

	RSpec::Core::RakeTask.new(:spec_main) do |t|
		spec_files = FileList[]
		spec_files.concat(main_specs)

		# trick t.pattern into accepting a list of files (otherwise deprecated)
		# otherwise globbing does not work on Windows (only first file is matched)
		t.pattern = spec_files

		t.rspec_opts = "--color --format documentation"
	end

	RSpec::Core::RakeTask.new(:spec_all) do |t|
		spec_files = FileList[]
		spec_files.concat(all_specs)

		# trick t.pattern into accepting a list of files (otherwise deprecated)
		# otherwise globbing does not work on Windows (only first file is matched)
		t.pattern = spec_files

		t.rspec_opts = "--color --format documentation"
	end

	# Make 'Rspec test run' the default task
	task :default => :spec_offline
rescue LoadError
	# no rspec available
end
