require File.join(File.expand_path(File.dirname(__FILE__)), "..", "spec_helper")

describe BillForward do
	describe 'Client' do
		describe '#new' do
			before :all do
				@client = BillForwardTest::TEST_CLIENT
			end
  			it "should find empty results upon looking up non-existent ID" do
  				account_id = "nonexist"
  				# begin 
  				# 	account = @client.get_first "accounts/#{account_id}"
  				# rescue BillForward::ApiClientException => e
  				# end
  				expect{@client.get_first "accounts/#{account_id}"}.to raise_error(BillForward::ClientException, "Cannot get first; request returned empty list of results.")

  				#log account
  				#expect(@client.get_first "subscriptions/#{subscription_id}").to eq("BillForward API call failed")
  			# 	subscription = @client.get_first "subscriptions/#{subscription_id}"

  			end
  		end
	end
end