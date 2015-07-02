module BillForward
	class BillingEntity
		# legacy Ruby gives us this 'id' chuff. we kinda need it back.
		undef id if defined? id
		attr_accessor :_client

		def initialize(state_params = nil, client = nil)
			raise AbstractInstantiateError.new('This abstract class cannot be instantiated!') if self.class == MutableEntity
			
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
			@_state_params.instance_eval { undef id if defined? id }
			# populate state params now
			unserialize_all state_params
		end

		@@payload_verbs = ['post', 'put']
		@@no_payload_verbs = ['get', 'delete']
		@@all_verbs = @@payload_verbs + @@no_payload_verbs

		class << self
			attr_accessor :resource_path

			def singleton_client
				Client.default_client
			end

			def build_entity_array(entity_hashes)
				TypeCheck.verifyObj(Array, entity_hashes, 'entity_hashes')

				entity_hashes.map do |hash|
					self.build_entity(hash)
				end
			end

			def build_entity(entity)
				if entity.is_a? Hash
					# either we are given a serialized entity
					# we must unserialize it

					# this entity should the same client as we do
					client = @_client

					return self.new(entity, client)
				end
				if entity.is_a? self
					# or we are given an already-constructed entity
					# just return it as-is

					# for consistency we might want to set this entity to use the same client as us. Let's not for now.
					return entity
				end
				if
					expectedClassName = self.name
					actualClassName = entity.class.name
					raise TypeError.new("Expected instance of either: 'Hash' or '#{expectedClassName}' at argument 'entity'. "+
						"Instead received: '#{actualClassName}'")
				end

				new_entity
			end

			def request_ambiguous(*args)
				plurality = args.shift
				verb = args.shift
				endpoint = args.shift

				payload = nil;
				haspayload = @@payload_verbs.include?(verb)
				if haspayload
          			payload = args.shift
          		end

				query_params = args.shift
				custom_client = args.shift

				client = client.nil? \
				? singleton_client \
				: custom_client

				route = resource_path.path
				url_full = "#{route}/#{endpoint}"
				method = "#{verb}_#{plurality}"

				arguments = [url_full, query_params]
				arguments.insert(1, payload) if haspayload

				client.send(method.intern, *arguments)
			end

			def request_many(*args)
				arguments = ['many']+args
				results = self.send(:request_ambiguous, *arguments)
				self.build_entity_array(results)
			end

			def request_first(*args)
				arguments = ['first']+args
				result = self.send(:request_ambiguous, *arguments)
				self.build_entity(result)
			end

			def get_by_id(id, query_params = {}, custom_client = nil)
				raise ArgumentError.new("id cannot be nil") if id.nil?

				endpoint = sprintf('%s',
					ERB::Util.url_encode(id)
					)

				self.request_first('get', endpoint, query_params, custom_client)
			end

			def get_all(query_params = {}, custom_client = nil)

				endpoint = ''

				self.request_many('get', endpoint, query_params, custom_client)
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

		def to_ordered_hash
			ordered_hash = hash_with_type_at_top(@_state_params)
			ordered_hash
		end

		def to_json(*a)
			ordered_hash = to_ordered_hash
			ordered_hash.to_json
			# @_state_params.to_json
		end

		def to_unordered_hash
			json_string = to_json
			JSON.parse(json_string)
		end

		def to_s
			parsed = to_unordered_hash
			JSON.pretty_generate(parsed)
		end

		def serialize
			to_json
		end

	protected
		def hash_with_type_at_top(hash)
			new_hash = OrderedHashWithDotAccess.new

			# API presently requires '@type' (if present) to be first key in JSON
			if hash.has_key? '@type'
				# insert existing @type as first element in ordered hash
				new_hash['@type'] = hash.with_indifferent_access['@type']
			end

			# add key-value pairs excepting '@type' back in
			# no, we don't care about the order of these.
			hash.with_indifferent_access.reject {|key, value| key == '@type'}.each do |key, value|
				new_hash[key] = value
			end

			return new_hash
		end

		def set_state_param(key, value)
			@_state_params[key] = value
			get_state_param(key)
		end

		def get_state_param(key)
			@_state_params[key]
		end

		def unserialize_all(hash)
			TypeCheck.verifyObj(Hash, hash, 'hash')

			hash.each do |key, value|
				unserialized = unserialize_one value
				set_state_param(key, unserialized)
			end
		end

		def unserialize_hash(hash)
			TypeCheck.verifyObj(Hash, hash, 'hash')

			# API presently requires '@type' (if present) to be first key in JSON
			hash = hash_with_type_at_top(hash)

			hash.each do |key, value|
				# recurse down, so that all nested hashes get same treatment
				unserialized = unserialize_one value

				# replace with unserialized version
				hash[key] = unserialized
			end

			hash
		end

		def unserialize_array(array)
			TypeCheck.verifyObj(Array, array, 'array')

			array.each_with_index do |value, index|
				# recurse down, so that all nested hashes get same treatment
				unserialized = unserialize_one value

				# replace with unserialized version
				array[index] = unserialized
			end

			array
		end

		def unserialize_one(value)
			if value.is_a? Hash
				return unserialize_hash(value)
			end
			if value.is_a? Array
				return unserialize_array(value)
			end
			value
		end

		def unserialize_entity(key, entity_class, hash)
			# ensure that the provided entity class derives from BillingEntity
			TypeCheck.verifyClass(BillingEntity, entity_class, 'entity_class')
			TypeCheck.verifyObj(Hash, hash, 'hash')

			# register the entity as one that requires bespoke serialization
			@_registered_entities[key] = entity_class
			# if key exists in the provided hash, add it to current entity's model
			if hash.has_key? key
				entity = entity_class.build_entity(hash[key])
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
				entities = entity_class.build_entity_array(hash[key])
				set_state_param(key, entities)
			end
		end
	end
end