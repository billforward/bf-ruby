# BillForwardApiClient

This client library provides (via Ruby) easy access to the BillForward API.

## Installation

Add this line to your application's Gemfile and run `bundle`:

```ruby
gem 'bill_forward', :git => 'git@github.com:billforward/bf-ruby.git', :branch => 'master'
```

Or install this source as a local gem using:

```bash
bundle
gem build bill_forward.gemspec
gem install bill_forward
```

## Usage
### Including the Gem

Once installed, require the BillForward gem:

```ruby
require 'bill_forward'
```

### Getting Credentials
You will need an API token. First log into your [Sandbox account](https://app-sandbox.billforward.net/login/#/) ([register](https://app-sandbox.billforward.net/register/#/) if necessary).

Then [generate an API token](https://app-sandbox.billforward.net/setup/#/personal/api-keys).

We support also client-id and client-secret authentication. For details, please [contact BillForward support](http://www.billforward.net/contact-us/).

### Connecting

Create a default Client. Requests will be sent using its credentials:

```ruby
my_client = BillForward::Client.new(
    :host =>      "API URL goes here",
    :api_token => "API token goes here"
)
BillForward::Client.default_client = my_client
```

### Invocation

##### Getting single entities:

e.g. Get Subscription by ID:

```ruby
subscription = BillForward::Subscription.get_by_id '3C39A79F-777E-4BDF-BDDC-221652F74E9D'
puts subscription
```

##### Accessing entity variables:

The entity can be accessed as a HashWithIndifferentAccess, or as an array.

```ruby
# The following are equivalent:
puts subscription.id
puts subscription['id']
puts subscription[:id]
```

##### Getting a list of entities:

e.g. List Accounts

```ruby
query_params = {
	'records'  => 3,
	'order_by' => 'created',
	'order'    => 'ASC'
}
accounts = BillForward::Account.get_all query_params
puts accounts
```

##### Creating an entity:

e.g. Create simple Account

```ruby
created_account = BillForward::Account.create
```

e.g. Create complex Account

```ruby
# Create an account with a profile (where the profile has addresses)
addresses = Array.new
addresses.push(
	BillForward::Address.new({
	'addressLine1' => 'address line 1',
    'addressLine2' => 'address line 2',
    'addressLine3' => 'address line 3',
    'city' => 'London',
    'province' => 'London',
    'country' => 'United Kingdom',
    'postcode' => 'SW1 1AS',
    'landline' => '02000000000',
    'primaryAddress' => true
	}))
profile = BillForward::Profile.new({
	'email' => 'always@testing.is.moe',
	'firstName' => 'Test',
	'addresses' => addresses
	})
account = BillForward::Account.new({
	'profile' => profile
	})
created_account = BillForward::Account.create account
puts created_account
```

##### Updating an entity

```ruby
gotten_account = BillForward::Account.get_by_id '908AF77A-0E5D-4D80-9B91-31EDE9962BF6'
gotten_account.profile.email = 'sometimes@testing.is.moe'
updated_account = gotten_account.save() # or: gotten_account.profile.save()
puts updated_account
```

## Development
### Building
Clone the source, then run `bundle`.
```bash
bundle
```
If ever you add a new dependency, you will need to run this again.

To install the gem, run:
```ruby
gem build bill_forward.gemspec
gem install bill_forward
```

### Running tests
Development is decidedly test-driven.

We use RSpec for testing.

Run offline tests with:
```bash
rake
```

If you wish to run online tests also, you will need to declare some test constants. Create a file `test_constants.rb` in the directory `spec/`, containing the following declarations:

```ruby
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
end
```

Run main functional tests + offline tests with:
```bash
rake spec_main
```

There are further tests still that can be run, but these are situational -- for example, they require an invoice to exist already, or require credentials to be declared for a payment gateway.

You can specify constants for use in situational tests in the usual test constants file, as before:

```ruby
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
end
```

Run main functional tests + offline tests + situational tests with:
```bash
rake spec_all
```