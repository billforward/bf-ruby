# BillForwardApiClient

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'bill_forward_api_client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bill_forward_api_client

## Usage

TODO: Write usage instructions here

Initialization:

```ruby
BILLFORWARD_CLIENT_ID=#to be provided by billforward
BILLFORWARD_CLIENT_SECRET=#to be provided by billforward
BILLFORWARD_API_HOST=#https://api.billforward.net/{obtain api version from billforward}/
BILLFORWARD_USERNAME=#organization username
BILLFORWARD_PASSWORD=#organization password
BILLFORWARD_ENVIRONMENT=#'development' or 'production'
```

---

```ruby
BILL_FORWARD_API_CLIENT = BillForward::ApiClient.new(
    ENV["BILLFORWARD_API_HOST"],
    ENV["BILLFORWARD_CLIENT_ID"],
    ENV["BILLFORWARD_CLIENT_SECRET"],
    ENV["BILLFORWARD_USERNAME"],
    ENV["BILLFORWARD_PASSWORD"],
    ENV["BILLFORWARD_ENVIRONMENT"]
)
```

Getting single entities:

e.g. subscription with ID:

```ruby
subscription = BILL_FORWARD_API_CLIENT.get_first "subscriptions/#{subscription_id}"
```

Accessing entity variables:

Use ["field"] e.g.

```ruby
puts subscription["id"]
```

Getting a list of entities:

e.g. list subscriptions

```ruby
subscriptions = BILL_FORWARD_API_CLIENT.get_results "subscriptions?records=200&order_by=CREATED&order=ASC"
puts subscriptions.length
```

Getting organization_id (this is used for creating entities)

```ruby
organization_id = BILL_FORWARD_API_CLIENT.get_organization_id
```

Creating single entities:

e.g. account

```ruby
created_account = BILL_FORWARD_API_CLIENT.post_first("accounts", {
      :organizationID => organization_id, #required, can be obtained via
      :profile => {
          :firstName => first_name,
          :lastName => last_name,
          :mobile => phone_number,
          :email => email
      }
  })

created_account["profile"]["firstName"] = "Bob"
```

Updating single entities

```ruby
updated_account = BILL_FORWARD_API_CLIENT.put_first("accounts", created_account)
```