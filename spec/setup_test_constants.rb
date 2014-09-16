# constants include BillForward credentials, required for running functional tests.
# this file, ignored from version control, allows users to specify credentials for a test account
test_constants_file = File.join(File.expand_path(File.dirname(__FILE__)), "test_constants.rb")
if (File.exist?(test_constants_file))
	puts "using test constants from #{test_constants_file}"
	require test_constants_file
else
	puts 'using default test constants'
	# the following is a template for what your 'test_constants.rb' should contain.
	# however if used in this placeholder state, functional tests will not pass.
	module BillForwardTest
		BILLFORWARD_API_HOST='insert-API-URL-here'
		BILLFORWARD_ENVIRONMENT="development"

		BILLFORWARD_API_TOKEN="insert-access-token-here"

		### alternatively:
		# (these values are used if you leave API token blank)
		# authenticate using OAUTH:
		BILLFORWARD_USERNAME="insert-username"
		BILLFORWARD_PASSWORD="insert-password"
		BILLFORWARD_CLIENT_ID="insert-client-id"
		BILLFORWARD_CLIENT_SECRET="insert-client-secret"
	end
end

# create BillForward client for use in all tests
# requires working credentials only when running functional tests
module BillForwardTest
	if (BillForwardTest::BILLFORWARD_API_TOKEN == '')
		# Authenticate using OAuth; username and password
		TEST_CLIENT = BillForward::Client.new(
				    :host =>          BillForwardTest::BILLFORWARD_API_HOST,
				    :environment =>   BillForwardTest::BILLFORWARD_ENVIRONMENT,
				    :username =>      BillForwardTest::BILLFORWARD_USERNAME,
				    :password =>      BillForwardTest::BILLFORWARD_PASSWORD,
				    :client_id =>     BillForwardTest::BILLFORWARD_CLIENT_ID,
				    :client_secret => BillForwardTest::BILLFORWARD_CLIENT_SECRET
					)
	else
		# Authenticate instead using access token
		TEST_CLIENT = BillForward::Client.new(
				    :host =>          BillForwardTest::BILLFORWARD_API_HOST,
				    :environment =>   BillForwardTest::BILLFORWARD_ENVIRONMENT,
				    :api_token =>     BillForwardTest::BILLFORWARD_API_TOKEN
					)
	end
end