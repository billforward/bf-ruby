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

        TypeCheck.verify(Client, default_client, 'default_client')
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
      TypeCheck.verify(Hash, options, 'options')

      if options[:host] and options[:environment]
        @host = options[:host]
        @environment = options[:environment]
      else
        raise ClientInstantiationException.new "Failed to initialize BillForward API Client\n" +
                                         "Required parameters: :host and :environment, and either [:api_token] or all of [:client_id, :client_secret, :username, :password].\n" +
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
      # @host = host
      # @client_id = client_id
      # @client_secret = client_secret
      # @username = username
      # @password = password
      # @environment = environment

      @authorization = nil
      @organization_id = nil
    end

    def log(*args)
      if @environment == "development"
        puts *args
      end
    end

    def get_organization_id
      return @organization_id unless @organization_id.nil?

      organizations = get("organizations/mine")

      return nil if organizations.nil?

      @organization_id = (organizations["results"] and organizations["results"].length > 0) ? organizations["results"][0]["id"] : nil
    end

    def get_results(url)
      response = get(url)

      return [] if response.nil? or response["results"].length == 0

      response["results"]
    end

    def get_first(url)
      response = get(url)

      raise IndexError.new("Cannot get first; request returned empty list of results.") if response.nil? or response["results"].length == 0

      response["results"][0]
    end

    def retire_first(url)
      response = retire(url)

      return nil if response.nil? or response["results"].length == 0

      response["results"][0]
    end

    def put_first(url, data)
      response = put(url, data)

      return nil if response.nil? or response["results"].length == 0

      response["results"][0]
    end

    def post_first(url, data)
      response = post(url, data)

      return nil if response.nil? or response["results"].length == 0

      response["results"][0]
    end

    def post_first!(url, data)
      response = post!(url, data)

      return nil if response.nil? or response["results"].length == 0

      response["results"][0]
    end

    def get(url)
      log "getting #{url}"
      token = get_token

      log "token: #{token}"
      return nil if token.nil?

      begin
        #RestClient.proxy = "http://127.0.0.1:8888"
        response = RestClient.get("#{@host}#{url}",
                                  {
                                      :Authorization => "Bearer #{token}"
                                  })

        #log "response: "+response.to_str
        #log JSON.pretty_generate(JSON.parse(response.to_str))
        #log response.to_str

        return JSON.parse(response.to_str)
      rescue => e
        log e
        if e.respond_to? "response"
          raise ClientException.new "BillForward API call failed", e.response.to_str
        else
          raise ClientException.new "BillForward API call failed"
        end
      end
    end

    def retire(url)
      log "retiring #{url}"
      token = get_token

      log "token: #{token}"
      return nil if token.nil?

      begin
        response = RestClient.delete("#{@host}#{url}",
                                     {
                                         :Authorization => "Bearer #{token}"
                                     })

        log "response: #{response.to_str}"

        return JSON.parse(response.to_str)
      rescue => e
        if e.respond_to? "response"
          raise ClientException.new "BillForward API call failed", e.response.to_str
        else
          raise ClientException.new "BillForward API call failed"
        end
        return nil
      end
    end

    def post(url, data = nil)
      log "posting #{url}"
      log JSON.pretty_generate(data) if (not data.nil?) and @environment == "development"

      token = get_token

      log "token: #{token}"
      return nil if token.nil?

      begin
        response = RestClient.post("#{@host}#{url}",
                                   data.to_json,
                                   :content_type => :json,
                                   :accept => :json,
                                   :Authorization => "Bearer #{token}")

        log "response: #{response.to_str}"

        return JSON.parse(response.to_str)
      rescue => e
        if e.respond_to? "response"
          raise ClientException.new "BillForward API call failed", e.response.to_str
        else
          raise ClientException.new "BillForward API call failed"
        end
      end
    end

    def post!(url, data = nil)
      log "posting #{url}"
      log JSON.pretty_generate(data) if (not data.nil?) and @environment == "development"

      token = get_token

      log "token: #{token}"
      raise ApiTokenException, "Could not get API Token" if token.nil?

      begin
        response = RestClient.post("#{@host}#{url}",
                                   data.to_json,
                                   :content_type => :json,
                                   :accept => :json,
                                   :Authorization => "Bearer #{token}")

        log "response: #{response.to_str}"

        return JSON.parse(response.to_str)
      rescue => e
        if e.respond_to? "response"
          log "error", e.response.to_str
          raise ClientException.new "BillForward API call failed", e.response
        else
          log e
          raise ClientException.new "BillForward API call failed", nil
        end

      end
    end

    def put(url, data = nil)
      log "putting #{url}"
      log JSON.pretty_generate(data) if (not data.nil?) and @environment == "development"

      token = get_token

      log "token: #{token}"
      return nil if token.nil?

      begin
        response = RestClient.put("#{@host}#{url}",
                                  data.to_json,
                                  :content_type => :json,
                                  :accept => :json,
                                  :Authorization => "Bearer #{token}")

        log "response: #{response.to_str}"

        return JSON.parse(response.to_str)
      rescue => e
        if e.respond_to? "response"
          log "error", e.response.to_str
        else
          log e
        end
        return nil
      end
    end

    private

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
