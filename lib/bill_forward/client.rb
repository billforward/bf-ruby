module BillForward
  class ClientException < Exception
    attr_accessor :response

    def initialize(message, response=nil)
      super(message)

      begin
        if response.nil?
          self.response = nil
        else
          self.response = JSON.parse response
        end
      rescue => e
        self.response = nil
      end
    end
  end

  class ClientInstantiationException < Exception
  end

  class ApiError < Exception
    attr_reader :json
    attr_reader :raw

    def initialize(json, raw)
      @json = json
      @raw = raw
    end
  end

  class ApiAuthorizationError < ApiError
  end

  class ApiTokenException < ClientException

  end

  class Client
    @@payload_verbs = ['post', 'put']
    @@no_payload_verbs = ['get', 'delete']
    @@all_verbs = @@payload_verbs + @@no_payload_verbs

    attr_accessor :host
    attr_accessor :use_logging
    attr_accessor :api_token

    # provide access to self statics
    class << self
      # default client is a singleton client
      attr_reader :default_client
      def default_client=(default_client)
        if (default_client == nil)
          # meaningless, but required for resetting this class after a test run
          @default_client = nil
          return
        end

        TypeCheck.verifyObj(Client, default_client, 'default_client')
        @default_client = default_client
      end
      def default_client()
        raise ClientInstantiationException.new("Failed to get default BillForward API Client; " +
           "'default_client' is nil. Please set a 'default_client' first.") if
        @default_client.nil?
        @default_client
      end
    end


    # Constructs a client, and sets it to be used as the default client.
    # @param options={} [Hash] Options with which to construct client
    # 
    # @return [Client] The constructed client
    def self.make_default_client(options)
      constructedClient = self.new(options)
      self.default_client = constructedClient
    end

    def initialize(options={})
      TypeCheck.verifyObj(Hash, options, 'options')
      @use_logging = options[:use_logging]

      if options[:host]
        @host = options[:host]
      else
        raise ClientInstantiationException.new "Failed to initialize BillForward API Client\n" +
                                         "Required parameters: :host, and either [:api_token] or all of [:client_id, :client_secret, :username, :password].\n" +
                                         "Supplied Parameters: #{options}"
      end

      if options[:use_proxy]
        @use_proxy = options[:use_proxy]
        @proxy_url = options[:proxy_url]
      end

      if options[:api_token]
        @api_token = options[:api_token]
      else
        @api_token = nil
        if options[:client_id] and options[:client_secret] and options[:username] and options[:password]
          @client_id = options[:client_id]
          @client_secret = options[:client_secret]
          @username = options[:username]
          @password = options[:password]
        else
          raise ClientException.new "Failed to initialize BillForward API Client\n"+
                                           "Required parameters: :host and :use_logging, and either [:api_token] or all of [:client_id, :client_secret, :username, :password].\n" +
                                           "Supplied Parameters: #{options}"
        end

      end

      @authorization = nil
    end

    def execute_request(verb, url, token, payload=nil)
      # Enable Fiddler:
      if @use_proxy
        RestClient.proxy = @proxy_url
      end
      
      # content_type seems to be broken on generic execute.
      # darn.
      # RestClient::Request.execute(options)
      options = {
        :Authorization => "Bearer #{token}",
        :accept => 'application/json'
      }

      haspayload = @@payload_verbs.include?(verb)

      if (haspayload)
        options.update(:content_type => 'application/json')
      end

      args = [url, options]
      args.insert(1, payload) if haspayload

      RestClient.send(verb.intern, *args)
    end

    @@all_verbs.each do |action|
      define_method(action.intern) do |*args|
        verb = action
        url = args.shift
        payload = nil
        if @@payload_verbs.include?(verb)
          payload = args.shift
          TypeCheck.verifyObj(String, payload, 'payload')
        end

        query_params = args.shift || {}
        TypeCheck.verifyObj(Hash, query_params, 'query_params')

        self.send(:request, *[verb, url, query_params, payload])
      end
      define_method("#{action}_first".intern) do |*args|
        response = self.send(action.intern, *args)

        raise IndexError.new("Cannot get first; request returned empty list of results.") if response.nil? or response["results"].length == 0

        response["results"].first
      end
    end

    alias_method :retire, :delete
    alias_method :retire_first, :delete_first

    private
      def uri_encode(params = {})
        TypeCheck.verifyObj(Hash, params, 'params')

        encoded_params = Array.new

        params.each do |key, value|
          encoded_key = ERB::Util.url_encode key
          encoded_value = ERB::Util.url_encode value
          encoded_params.push("#{encoded_key}=#{encoded_value}")
        end
        query = encoded_params.join '&'
        
      end

      def request(verb, url, params={}, payload=nil)
        full_url = "#{@host}#{url}"

        # Make params into query parameters
        full_url += "?#{uri_encode(params)}" if params && params.any?
        token = get_token

        log "#{verb} #{url}"
        log "token: #{token}"

        begin
          response = execute_request(verb, full_url, token, payload)

          parsed = JSON.parse(response.to_str)
          pretty = JSON.pretty_generate(parsed)
          log "response: \n#{pretty}"

          return parsed
        rescue SocketError => e
          handle_restclient_error(e)
        rescue NoMethodError => e
          # Work around RestClient bug
          if e.message =~ /\WRequestFailed\W/
            e = APIConnectionError.new('Unexpected HTTP response code')
            handle_restclient_error(e)
          else
            raise
          end
        rescue RestClient::ExceptionWithResponse => e
          if rcode = e.http_code and rbody = e.http_body
            handle_api_error(rcode, rbody)
          else
            handle_restclient_error(e)
          end
        rescue RestClient::Exception, Errno::ECONNREFUSED => e
          handle_restclient_error(e)
        end
      end

      def handle_restclient_error(e)
        connection_message = "Please check your internet connection and try again. "

        case e
        when RestClient::RequestTimeout
          message = "Could not connect to BillForward (#{@host}). #{connection_message}"
        when RestClient::ServerBrokeConnection
          message = "The connection to the server (#{@host}) broke before the " \
            "request completed. #{connection_message}"
        when SocketError
          message = "Unexpected error communicating when trying to connect to BillForward. " \
            "Please confirm that (#{@host}) is a BillForward API URL. "
        else
          message = "Unexpected error communicating with BillForward. "
        end

        raise ClientException.new(message + "\n\n(Network error: #{e.message})")
      end

      def handle_api_error(rcode, rbody)
        begin
          # Example error JSON:
          # {
          #    "errorType" : "ValidationError",
          #    "errorMessage" : "Validation Error - Entity: Subscription Field: type Value: null Message: may not be null\nValidation Error - Entity: Subscription Field: productID Value: null Message: may not be null\nValidation Error - Entity: Subscription Field: name Value: null Message: may not be null\n",
          #    "errorParameters" : [ "type", "productID", "name" ]
          # }

          error = JSON.parse(rbody)

          errorType = error['errorType']
          errorMessage = error['errorMessage']
          if (error.key? 'errorParameters')
            errorParameters = error['errorParameters']
            raise_message = "\n====\n#{rcode} API Error.\nType: #{errorType}\nMessage: #{errorMessage}\nParameters: #{errorParameters}\n====\n"  
          else
            if (errorType == 'Oauth')
              split = errorMessage.split(', ')

              error = split.first.split('=').last
              description = split.last.split('=').last

              raise_message = "\n====\n#{rcode} Authorization failed.\nType: #{type}\nError: #{error}\nDescription: #{description}\n====\n"

              raise ApiAuthorizationError.new(error, rbody), raise_message
            else
              raise_message = "\n====\n#{rcode} API Error.\nType: #{errorType}\nMessage: #{errorMessage}\n====\n"  
            end
          end
          
          raise ApiError.new(error, rbody), raise_message
        end

        raise_message = "\n====\n#{rcode} API Error.\n Response body: #{rbody}\n====\n"
        raise ApiError.new(nil, rbody), raise_message
      end

      def log(*args)
        if @use_logging
          puts *args
        end
      end

      def get_token
        if @api_token
          @api_token
        else
          if @authorization and Time.now < @authorization["expires_at"]
            return @authorization["access_token"]
          end
          begin
            response = RestClient.get("#{@host}oauth/token", :params => {
                :username => @username,
                :password => @password,
                :client_id => @client_id,
                :client_secret => @client_secret,
                :grant_type => "password"
            }, :accept => :json)

            @authorization = JSON.parse(response.to_str)
            @authorization["expires_at"] = Time.now + @authorization["expires_in"]

            @authorization["access_token"]
          rescue => e
            if e.respond_to? "response"
              log "BILL FORWARD CLIENT ERROR", e.response
            else
              log "BILL FORWARD CLIENT ERROR", e, e.to_json
            end
            nil
          end
        end
      end
  end
end
