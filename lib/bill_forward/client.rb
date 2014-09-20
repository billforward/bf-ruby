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
  end

  class ApiAuthorizationError < ApiError
  end

  class ApiTokenException < ClientException

  end

  class Client
    attr_accessor :host
    attr_accessor :environment
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
    def self.makeDefaultClient(options)
      constructedClient = self.new(options)
      self.default_client = constructedClient
    end

    def initialize(options={})
      TypeCheck.verifyObj(Hash, options, 'options')
      options[:environment] ||= "default"
      @environment = options[:environment]

      if options[:host]
        @host = options[:host]
      else
        raise ClientInstantiationException.new "Failed to initialize BillForward API Client\n" +
                                         "Required parameters: :host, and either [:api_token] or all of [:client_id, :client_secret, :username, :password].\n" +
                                         "Supplied Parameters: #{options}"
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
                                           "Required parameters: :host and :environment, and either [:api_token] or all of [:client_id, :client_secret, :username, :password].\n" +
                                           "Supplied Parameters: #{options}"
        end

      end

      @authorization = nil
    end



    # def get_results(url)
    #   response = get(url)

    #   return [] if response.nil? or response["results"].length == 0

    #   response["results"]
    # end

    def get_first(url, params={})
      response = get(url, params)

      raise IndexError.new("Cannot get first; request returned empty list of results.") if response.nil? or response["results"].length == 0

      response["results"][0]
    end

    def retire_first(url, params={})
      response = retire(url, params)

      raise IndexError.new("Cannot get first; request returned empty list of results.") if response.nil? or response["results"].length == 0

      response["results"][0]
    end

    def put_first(url, data, params={})
      response = put(url, data, params)

      raise IndexError.new("Cannot get first; request returned empty list of results.") if response.nil? or response["results"].length == 0

      response["results"][0]
    end

    def post_first(url, data, params={})
      response = post(url, data, params)

      raise IndexError.new("Cannot get first; request returned empty list of results.") if response.nil? or response["results"].length == 0

      response["results"][0]
    end

    def execute_request(method, url, token, payload=nil)
      # RestClient.proxy = "http://127.0.0.1:8888"
      # content_type seems to be broken on generic execute.
      # darn.
      # RestClient::Request.execute(options)
      options = {
        :Authorization => "Bearer #{token}"
      }
      if (method == 'post' || method == 'put')
        options.update(:content_type => 'application/json',
          :accept => 'application/json'
        )
      end

      if (method == 'post')
        RestClient.post(url, payload, options)
      elsif (method == 'put')
        RestClient.put(url, payload, options)
      elsif (method == 'get')
        RestClient.get(url, options)
      elsif (method == 'delete')
        RestClient.delete(url, options)
      end
    end

    def get(url, params={})
      TypeCheck.verifyObj(Hash, params, 'params')
      request('get', url, params, nil)
    end

    def retire(url, params={})
      TypeCheck.verifyObj(Hash, params, 'params')
      request('delete', url, params, nil)
    end

    def post(url, data, params={})
      TypeCheck.verifyObj(Hash, data, 'data')
      TypeCheck.verifyObj(Hash, params, 'params')
      request('post', url, params, data)
    end

    def put(url, data, params={})
      TypeCheck.verifyObj(Hash, data, 'data')
      TypeCheck.verifyObj(Hash, params, 'params')
      request('put', url, params, data)
    end

    private
      def request(method, url, params={}, payload=nil)
        full_url = "#{@host}#{url}"

        # Make params into query parameters
        full_url += "#{URI.parse(url).query ? '&' : '?'}#{uri_encode(params)}" if params && params.any?
        token = get_token

        log payload

        unless (payload.nil?)
          payload = payload.to_json.to_s
        end

        log "#{method} #{url}"
        log "token: #{token}"
        log "payload: #{payload}"

        begin
          response = execute_request(method, full_url, token, payload)

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
            raise_message = "\n====\n#{rcode} API Error.\nType: #{errorType}\nMessage: #{errorMessage}\n====\n"  
          end
          
          raise ApiError.new raise_message

        rescue JSON::ParserError
          begin
            # Maybe it's XML then; it could look like this:
            # <?xml version="1.0" encoding="UTF-8"?>
            # <error>
            #    <errorType>Oauth</errorType>
            #    <errorMessage>error="invalid_token", error_description="Invalid access token: 046898af-fa7a-4394-8a52-7dae28668b08"</errorMessage>
            # </error>
            xml = Nokogiri::XML(rbody)

            type = xml.at_xpath("//error//errorType").content
            message = xml.at_xpath("//error//errorMessage").content

            split = message.split(', ')

            error = split.first.split('=').last
            description = split.last.split('=').last

            raise_message = "\n====\n#{rcode} Authorization failed.\nType: #{type}\nError: #{error}\nDescription: #{description}\n====\n"

            raise ApiAuthorizationError.new raise_message
          rescue Nokogiri::SyntaxError
            raise_message = "\n====\n#{rcode} API Error.\n Response body: #{rbody}\n====\n"
            raise ApiError.new raise_message
          end  
        end

        raise_message = "\n====\n#{rcode} API Error.\n Response body: #{rbody}\n====\n"
        raise ApiError.new raise_message
      end

      def log(*args)
        if @environment == "development"
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
