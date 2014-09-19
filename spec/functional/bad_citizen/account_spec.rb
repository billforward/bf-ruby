require File.join(File.expand_path(File.dirname(__FILE__)), "..", "..", "spec_helper")
# we want unique numbers to test updates with
require 'SecureRandom'

describe BillForward::Account do
	before :all do
		@client = BillForwardTest::TEST_CLIENT
		BillForward::Client.default_client = @client
	end
	describe '::create' do
		context 'upon creating minimal account' do
			before :all do
				@created_account = BillForward::Account.create
			end
			subject (:account) { @created_account }
			it "can get property" do
				expect(account['@type']).to eq(BillForward::Account.resource_path.entity_name)
			end
			it "can be retired" do
				expect(account.deleted).to eq(false)

				retired_account = account.delete
				expect(retired_account.deleted).to eq(true)
			end
		end
		context 'upon creating account with profile' do
			describe 'the created account' do
				before :all do
					@email = 'always@testing.is.moe'
					profile = BillForward::Profile.new({
						'email' => @email,
	  					'firstName' => 'Test',
						})
					account = BillForward::Account.new({
						'profile' => profile
						})
					@created_account = BillForward::Account.create account
				end
				subject (:account) { @created_account }
				it "can get property" do
					expect(account['@type']).to eq(BillForward::Account.resource_path.entity_name)
				end
				it "has profile" do
					profile = account.get_profile
					expect(profile.email).to eq(@email)
				end
				context 'after creation' do
					before :all do
						@gotten_account = BillForward::Account.get_by_id @created_account.id
					end
					subject (:account) { @gotten_account }
					it "can be gotten" do
						expect(account['@type']).to eq(BillForward::Account.resource_path.entity_name)
						expect(account.id).to eq(@created_account.id)
					end
					it "can be updated" do
						expect(account.deleted).to eq(false)
						account.deleted = true
						expect(account.deleted).to eq(true)
						updated_account = account.save

						expect(updated_account.deleted).to eq(true)
					end
					describe "profile" do
						subject (:profile) { account.get_profile }
						it 'has expected properties' do
							expect(profile.email).to eq(@email)
						end
						it 'has updatable properties' do
							unique_value = SecureRandom.hex(10)
							profile.firstName = unique_value
							updated_profile = profile.save

							expect(updated_profile.firstName).to eq(unique_value)
						end
						it 'can update properties via cascade' do
							unique_value = SecureRandom.hex(10)
							profile.firstName = unique_value
							updated_account = account.save
							updated_profile = updated_account.profile
							
							expect(updated_profile.firstName).to eq(unique_value)
						end
					end
				end
			end
		end
	end
end