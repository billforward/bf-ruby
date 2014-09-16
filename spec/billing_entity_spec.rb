require 'spec_helper'
describe BillForward do
	describe 'BillingEntity' do
		before :all do
			@host="http://localhost:8080/RestAPI/"
			@environment="development"
			@token1="sometoken1"
			@token2="sometoken2"
			@dudclient1 = BillForward::Client.new(
			    :host => @host,
			    :environment => @environment,
			    :api_token => @token1
				)
			@dudclient2 = BillForward::Client.new(
			    :host => @host,
			    :environment => @environment,
			    :api_token => @token2
				)
		end
		describe '.client' do
			context 'with differing clients' do
				it 'differs on each entity' do
					entity1 = BillForward::Account.new(@dudclient1)
					entity2 = BillForward::Account.new(@dudclient2)
					expect(entity1.client.api_token).to eq(@token1)
					expect(entity2.client.api_token).to eq(@token2)
				end
			end
			context 'before creation of singleton client' do
				# note: this spec needs to run before any singleton clients are made
				it 'raises error' do
					expect{BillForward::Account.new}.to raise_error(BillForward::ClientInstantiationException)
				end
			end
			context 'with "set" singleton client' do
				it 'uses default client' do
					BillForward::Client.default_client = @dudclient1
					entity = BillForward::Account.new
					expect(entity.client.api_token).to eq(@token1)
				end
			end
			context 'with "made" singleton client' do
				it 'uses default client' do
					dudclient_options = {
					    :host => @host,
					    :environment => @environment,
					    :api_token => @token2
						}
					BillForward::Client.makeDefaultClient(dudclient_options)
					entity = BillForward::Account.new
					expect(entity.client.api_token).to eq(@token2)
				end
			end
			context 'despite "set" singleton client' do
				it 'prefers provided client to default' do
					BillForward::Client.default_client = @dudclient1
					entity = BillForward::Account.new(@dudclient2)
					expect(entity.client.api_token).to eq(@token2)
				end
			end
			context 'with change in singleton client' do
				context 'per instantiation' do
					it 'uses creation-time latest client' do
						BillForward::Client.default_client = @dudclient1
						entity1 = BillForward::Account.new
						expect(entity1.client.api_token).to eq(@token1)
						BillForward::Client.default_client = @dudclient2
						entity2 = BillForward::Account.new
						expect(entity2.client.api_token).to eq(@token2)
						expect(entity1.client.api_token).to eq(@token1)
					end
				end
				context 'before instantiation' do
					it 'uses same client on each entity' do
						BillForward::Client.default_client = @dudclient1
						BillForward::Client.default_client = @dudclient2
						entity1 = BillForward::Account.new
						entity2 = BillForward::Account.new
						expect(entity1.client.api_token).to eq(@token2)
						expect(entity2.client.api_token).to eq(@token2)
					end
				end
			end
		end
	end
end