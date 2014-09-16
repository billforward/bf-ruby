require 'spec_helper'
describe BillForward do
	describe 'Account' do
		describe '#new' do
			it "provides access to client" do
				host="http://localhost:8080/RestAPI/"
				environment="development"
				token="6f1f7465-fc16-4b9c-9ea0-f8c208a43ca6"
				dudclient = BillForward::Client.new(
				    :host => host,
				    :environment => environment,
				    :api_token => token
					)
				account = BillForward::Account.new(dudclient)
				expect(account.client.host).to eq(host)
			end
		end
		describe '::resource_path' do
			it "points to expected endpoint" do
				resource_path = BillForward::Account.resource_path
				expect(resource_path.path).to eq("accounts")
			end
		end
	end
end