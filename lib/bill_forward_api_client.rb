require "bill_forward_api_client/version"

require "rest-client"
require "json"

module BillForward
  class ApiClient
    def initialize(host, client_id, client_secret, username, password, environment)
      @host = host
      @client_id = client_id
      @client_secret = client_secret
      @username = username
      @password = password
      @environment = environment

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
        log "error", e.response.to_str
        return nil
      end
    end

    def post(url, data = nil)
      log "posting #{url}"
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
        log "error", e
        return nil
      end
    end

    def put(url, data = nil)
      log "putting #{url}"
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
        log "error", e.response.to_str
        return nil
      end
    end

    private

    def get_token
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

        access_token = @authorization["access_token"]
        return access_token
      rescue => e
        log "BILL FORWARD CLIENT ERROR", e.to_json
        return nil
      end
    end
  end

end