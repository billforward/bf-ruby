# constants include BillForward credentials, required for running functional tests.
# this file, ignored from version control, allows users to specify credentials for a test account
test_constants_file = File.join(File.expand_path(File.dirname(__FILE__)), "test_constants.rb")
if (File.exist?(test_constants_file))
	puts "using test constants from #{test_constants_file}"
	require test_constants_file
else
	puts 'using default test constants'
	# The following is a template for what your 'test_constants.rb' should contain.
	# If used in this placeholder state, functional tests will not pass.
	module BillForwardTest
		BILLFORWARD_API_HOST='insert-API-URL-here'
		BILLFORWARD_API_TOKEN="insert-access-token-here OR leave-blank-for-OAUTH"

		### alternatively:
		# (these values are used if you leave API token blank)
		# authenticate using OAUTH:
		BILLFORWARD_USERNAME="insert-username"
		BILLFORWARD_PASSWORD="insert-password"
		BILLFORWARD_CLIENT_ID="insert-client-id"
		BILLFORWARD_CLIENT_SECRET="insert-client-secret"


		# ---- Enable logging if you want (shows request and response bodies)
		USE_LOGGING=false


		# ---- Enable proxy if you want (for example to see requests in Fiddler)
		CLIENT_PROXY_ENABLED=false
		CLIENT_PROXY_URL="http://127.0.0.1:8888"


		## These constants are required only for running situational tests (not in the main run):
		# ---- Required for Authorize.Net gateway tests only
		AUTHORIZE_NET_LOGIN_ID = 'FILL IN WITH AUTHORIZE NET LOGIN ID'
		AUTHORIZE_NET_TRANSACTION_KEY = 'FILL IN WITH AUTHORIZE NET TRANSACTION KEY'
		# ---- Required for Authorize.Net tokenization tests only
		AUTHORIZE_NET_CUSTOMER_PROFILE_ID = 12345678 # FILL IN WITH AUTHORIZE NET CUSTOMER PROFILE ID
		AUTHORIZE_NET_CUSTOMER_PAYMENT_PROFILE_ID = 12345678 # FILL IN WITH AUTHORIZE NET CUSTOMER PAYMENT PROFILE ID
		AUTHORIZE_NET_CARD_LAST_4_DIGITS = 1234

		
		# ---- Required for Invoice tests only
		USUAL_INVOICE_ID = 'FILL IN WITH EXISTING INVOICE ID'
	end
end

# create BillForward client for use in all tests
# requires working credentials only when running functional tests
module BillForwardTest
	if (BillForwardTest::BILLFORWARD_API_TOKEN == '')
		# Authenticate using OAuth; username and password
		TEST_CLIENT = BillForward::Client.new(
				    :host =>          BillForwardTest::BILLFORWARD_API_HOST,
				    :use_logging =>   BillForwardTest::USE_LOGGING,
				    :username =>      BillForwardTest::BILLFORWARD_USERNAME,
				    :password =>      BillForwardTest::BILLFORWARD_PASSWORD,
				    :client_id =>     BillForwardTest::BILLFORWARD_CLIENT_ID,
				    :client_secret => BillForwardTest::BILLFORWARD_CLIENT_SECRET,
				    :use_proxy     => BillForwardTest::CLIENT_PROXY_ENABLED,
				    :proxy_url =>    BillForwardTest::CLIENT_PROXY_URL
					)
	else
		# Authenticate instead using access token
		TEST_CLIENT = BillForward::Client.new(
				    :host =>          BillForwardTest::BILLFORWARD_API_HOST,
				    :use_logging =>   BillForwardTest::USE_LOGGING,
				    :api_token =>     BillForwardTest::BILLFORWARD_API_TOKEN,
				    :use_proxy     => BillForwardTest::CLIENT_PROXY_ENABLED,
				    :proxy_url =>    BillForwardTest::CLIENT_PROXY_URL
					)
	end
end