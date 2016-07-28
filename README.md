# BillForwardApiClient

This client library provides (via Ruby) easy access to the BillForward API.

## Support

Until [commit 1ca55](https://github.com/billforward/bf-ruby/tree/1ca55ca8d361130c935df68e3b6496611221938a), [version 1.2016.117](https://rubygems.org/gems/bill_forward/versions/1.2016.117), the SDK targeted Ruby 1.8.7.

## Installation
### From Git

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

### From RubyGems mirror

Add the `bill_forward` gem to your application's Gemfile and run `bundle`:
```bash
source 'https://rubygems.org'
gem 'bill_forward'
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

## Documentation

View our [API Documentation](https://app-sandbox.billforward.net/#/api/method/accounts/POST?api=Ruby&path=%2Faccounts).

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

Maybe you find yourself running the above two snippets very often. 
You can invoke them more simply by running `tools/local_bundle_install.sh`.

### Invoking unpacked gem
The `scratch/` directory contains a Gemfile that includes this repo's gem, without having to repeatedly bundle and gem build & install upon changes.

Run `bundle` once in the `scratch/` directory to pull in its dependent gems.

You can recruit this Gemfile using a file like as `scratch/scratch.example.rb`. 
Make your own `scratch/scratch.rb` (this particular path is exempt from version control), or any file ending in `.scratch.rb` to play around with this gem locally.

In Sublime I use such a build system to run `.rb` scratch files:

```json
{
  "env": {
    "PATH":"${HOME}/.rvm/bin:${PATH}"
  },
  "cmd": ["rvm-auto-ruby", "-rubygems", "${file}" ],
  "selector": "source.ruby"
}
```

You'll find this build system in `tools/Ruby\ legacy.sublime-build`.

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

In Sublime I use such a build system to run individual `_spec.rb` specs:

```json
{
	"env": {
		"PATH":"${HOME}/.rvm/bin:${PATH}"
	},
	"cmd": ["rvm-auto-ruby","-S", "bundle", "exec", "rspec", "-I ${file_path}", "$file"],
	"working_dir": "${project_path}",
	"selector": "source.ruby",

	"windows":
	{
	  "cmd": ["rspec.bat", "-I ${file_path}", "$file"]
	}
}
```

You'll find this build system in `tools/RSpec.sublime-build`.

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

### Releasing

Bump the version in `lib/bill_forward/version.rb`, with a major version bump if there are breaking changes.

Minor revision is determined by [days since start of year](http://www.wolframalpha.com/input/?i=days+since+start+of+year) (rounded down).

If you publish twice in a day, it becomes day.1, day.2 and so on.

Build the gemspec locally:

```bash
gem build bill_forward.gemspec
```

Then publish the resulting gem:

```bash
gem push bill_forward-1.2015.217.gem
```