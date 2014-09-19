module BillForward
	class BillingEntity
		# legacy Ruby gives us this 'id' chuff. we kinda need it back.
		undef id unless defined? id
		attr_accessor :_client

		def initialize(state_params = nil, client = nil)
			client = self.class.singleton_client if client.nil?
			state_params = {} if state_params.nil?

			TypeCheck.verifyObj(Client, client, 'client')
			TypeCheck.verifyObj(Hash, state_params, 'state_params')

			@_registered_entities = Hash.new
			@_registered_entity_arrays = Hash.new

			@_client = client
			# initiate with empty state params
			# use indifferent hash so 'id' and :id are the same
			@_state_params = HashWithIndifferentAccess.new
			# legacy Ruby gives us this 'id' chuff. we kinda need it back.	
			@_state_params.instance_eval { undef :id unless defined? :id }
			# populate state params now
			unserialize_all state_params
		end

		class << self
			attr_accessor :resource_path

			def get_by_id(id, query_params = {}, customClient = nil)
				client = customClient
				client = singleton_client if client.nil?

				raise ArgumentError.new("id cannot be nil") if id.nil?
				TypeCheck.verifyObj(Hash, query_params, 'query_params')

				route = resource_path.path
				endpoint = ''
				url_full = "#{route}/#{endpoint}#{id}"

				response = client.get_first(url_full)

				# maybe use build_entity here for consistency
				self.new(response, client)
			end

			def get_all(query_params = {}, customClient = nil)
				client = customClient
				client = singleton_client if client.nil?
				
				TypeCheck.verifyObj(Hash, query_params, 'query_params')

				route = resource_path.path
				endpoint = ''
				url_full = "#{route}/#{endpoint}"

				response = client.get(url_full)
				results = response["results"]

				# maybe use build_entity_array here for consistency
				entity_array = Array.new
				# maybe it's an empty array, but that's okay too.
				results.each do |value|
					entity = self.new(value, client)
					entity_array.push(entity)
				end
				entity_array
			end

			def singleton_client
				Client.default_client
			end
		end

		def method_missing(method_id, *arguments, &block)
			# no call to super; our criteria is all keys.
			#setter
			if /^(\w+)=$/ =~ method_id.to_s
				return set_state_param($1, arguments.first)
			end
			#getter
			get_state_param(method_id.to_s)
		end

		def [](key)
			method_missing(key)
		end

		def []=(key, value)
			set_key = key.to_s+'='
			method_missing(set_key, value)
		end

		def to_json(*a)
			@_state_params.to_json
		end

		def to_hash(*a)
			json_string = to_json
			JSON.parse(to_s)
		end

		def to_s
			json_string = to_json
			JSON.pretty_generate(JSON.parse(json_string))
		end

	protected
		def set_state_param(key, value)
			@_state_params[key] = value
			get_state_param(key)
		end

		def get_state_param(key)
			@_state_params[key]
		end

		def unserialize_all(hash)
			hash.each do |key, value|
				unserialize_one key, value
			end
		end

		def unserialize_one(key, value)
			if value.is_a? Array

			#elsif value.is_a? String
			end
			set_state_param(key, value)
		end

		def unserialize_entity(key, entity_class, hash)
			# ensure that the provided entity class derives from BillingEntity
			TypeCheck.verifyClass(BillingEntity, entity_class, 'entity_class')
			TypeCheck.verifyObj(Hash, hash, 'hash')

			# register the entity as one that requires bespoke serialization
			@_registered_entities[key] = entity_class
			# if key exists in the provided hash, add it to current entity's model
			if hash.has_key? key
				entity = build_entity(entity_class, hash[key])
				set_state_param(key, entity)
			end
		end

		def unserialize_array_of_entities(key, entity_class, hash)
			# ensure that the provided entity class derives from BillingEntity
			TypeCheck.verifyClass(BillingEntity, entity_class, 'entity_class')
			TypeCheck.verifyObj(Hash, hash, 'hash')

			# register the array of entities as one that requires bespoke serialization
			@_registered_entity_arrays[key] = entity_class
			# if key exists in the provided hash, add it to current entity's model
			if hash.has_key? key
				entities = build_entity_array(entity_class, hash[key])
				set_state_param(key, entities)
			end
		end

		def build_entity_array(entity_class, entity_hashes)
			TypeCheck.verifyObj(Array, entity_hashes, 'entity_hashes')

			entity_array = Array.new
			# maybe it's an empty array, but that's okay too.
			entity_hashes.each do |value|
				new_entity = build_entity(entity_class, value)
				entity_array.push(new_entity)
			end
			entity_array
		end

		def build_entity(entity_class, entity)
			if entity.is_a? Hash
				# either we are given a serialized entity
				# we must unserialize it

				# this entity should the same client as we do
				client = @_client

				new_entity = entity_class.new(entity, client)
			elsif entity.is_a? entity_class
				# or we are given an already-constructed entity
				# just return it as-is

				# for consistency we might want to set this entity to use the same client as us. Let's not for now.
				new_entity = entity
			else
				expectedClassName = entity_class.name
				actualClassName = entity.class.name
				raise TypeError.new("Expected instance of either: 'Hash' or '#{expectedClassName}' at argument 'entity'. "+
					"Instead received: '#{actualClassName}'")
			end

			new_entity
		end
	end
end