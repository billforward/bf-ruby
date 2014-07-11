require "bill_forward_api_client/version"

require "rest-client"
require "json"

module BillForward
  class ApiClientException < Exception
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

  class ApiTokenException < ApiClientException

  end

  class ApiClient
    def initialize(options={})
      if options[:host] and options[:environment]
        @host = options[:host]
        @environment = options[:environment]
      else
        raise ApiClientException.new "Failed to initialize BillForward API Client\n" +
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
          raise ApiClientException.new "Failed to initialize BillForward API Client\n"+
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

      return nil if response.nil? or response["results"].length == 0

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
        response = RestClient.get("#{@host}#{url}",
                                  {
                                      :Authorization => "Bearer #{token}"
                                  })

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
          log "error", e.response.to_str
        else
          log e
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
          log "error", e.response.to_str
        else
          log e
        end
        return nil
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
          raise ApiClientException.new "BillForward API call failed", e.response
        else
          log e
          raise ApiClientException.new "BillForward API call failed", nil
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
