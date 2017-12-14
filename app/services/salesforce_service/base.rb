require 'restforce'
require 'facets/hash/rekey'

module SalesforceService
  # encapsulate all Salesforce querying functions in one handy service
  class Base
    class_attribute :retries
    class_attribute :timeout
    class_attribute :error
    class_attribute :force
    class_attribute :unit_data_tries
    self.retries = 0
    self.timeout = ENV['SALESFORCE_TIMEOUT'] ? ENV['SALESFORCE_TIMEOUT'].to_i : 10
    self.force = false

    def self.client
      Restforce.new(timeout: timeout)
    end

    def self.oauth_client
      Restforce.new(
        authentication_retries: 1,
        oauth_token: oauth_token,
        instance_url: ENV['SALESFORCE_INSTANCE_URL'],
        mashify: false,
        timeout: timeout,
      )
    end

    # run a Salesforce SOQL query
    def self.query(q)
      client.query(q)
    end

    def self.api_call(method = :get, endpoint, params, parse_response)
      self.error = nil
      apex_endpoint = "/services/apexrest#{endpoint}"
      response = oauth_client.send(method, apex_endpoint, params)
      process_response(response, parse_response)
    rescue Restforce::UnauthorizedError,
           Restforce::AuthenticationError,
           Faraday::ConnectionFailed,
           Faraday::TimeoutError => e
      if retries > 0
        self.retries = retries.to_i - 1
        oauth_token(true) if e.is_a? Restforce::UnauthorizedError
        retry
      else
        self.error = e.class.name
        message = params && params[:user_token_validation] ? 'user_token_validation' : nil
        # re-raise the same error
        raise e, message
      end
    end

    def self.api_get(endpoint, params = nil, parse_response = false)
      self.retries = 1
      api_call(:get, endpoint, params, parse_response)
    end

    def self.cached_api_get(endpoint, params = nil, parse_response = false)
      self.retries = 1
      key = "#{endpoint}#{params ? '?' + params.to_query : ''}"
      force_refresh = force || !ENV['CACHE_SALESFORCE_REQUESTS']
      if ENV['FREEZE_SALESFORCE_CACHE']
        expires_in = 10.years
      else
        expires_in = params ? 10.minutes : 1.day
      end
      Rails.cache.fetch(key, force: force_refresh, expires_in: expires_in) do
        api_call(:get, endpoint, params, parse_response)
      end
    end

    def self.api_post(endpoint, params = nil, parse_response = false)
      self.retries = 0
      # set the timeout to higher for POST methods
      prev_timeout = timeout
      self.timeout = 25
      result = api_call(:post, endpoint, params, parse_response)
      # set it back again to the default
      self.timeout = prev_timeout
      result
    end

    def self.api_delete(endpoint, params = nil, parse_response = false)
      api_call(:delete, endpoint, params, parse_response)
    end

    # NOTE: Have to use custom Faraday connection to send headers.
    def self.api_post_with_headers(endpoint, body = '', headers = {})
      self.retries = 1
      status = nil
      response = nil
      while retries > 0 && status != 200
        # NOTE: status will be 500 if there was an error with submission
        # e.g. DocumentType does not match Salesforce picklist
        # --
        # QUICK FIX for 401 issues: always force oauth_token refresh for these calls
        oauth_token(true)
        response = post_with_headers(endpoint, body, headers)
        status = response.status
        self.retries -= 1
        if status == 401
          # refresh oauth_token
          oauth_token(true)
        end
      end
      response
    end

    def self.post_with_headers(endpoint, body, headers = {})
      conn = Faraday.new(url: ENV['SALESFORCE_INSTANCE_URL'])
      conn.post "/services/apexrest#{endpoint}" do |req|
        headers.each do |k, v|
          req.headers[k] = v
        end
        req.headers['Authorization'] = "OAuth #{oauth_token}"
        req.body = body.to_json
      end
    end

    def self.oauth_token(force = false)
      Rails.cache.fetch('salesforce_oauth_token', force: force) do
        auth = client.authenticate!
        auth.access_token
      end
    end

    # move all listing attributes to the root level of the hash
    # this is partly to not have to totally refactor our JS code
    # after Salesforce changes w/ ListingDetails
    def self.flatten_response(body)
      return [] if body.blank?
      body.collect do |listing|
        listing.merge(listing['listing'] || {}).except('listing')
      end
    end

    def self.process_response(response, parse_response)
      if parse_response
        massage(flatten_response(response.body))
      else
        response.body
      end
    end

    # recursively remove "__c" and "__r" from all keys
    def self.massage(h)
      if h.is_a?(Hash)
        hash_massage(h)
      elsif h.is_a?(Array) or h.is_a?(Restforce::Collection)
        h.map { |i| massage(i) }
      elsif h.is_a?(Symbol) or h.is_a?(String)
        string_massage(h)
      else
        h
      end
    end

    def self.hash_massage(h)
      return h['records'].map { |i| massage(i) } if h.include?('records')
      # massage each hash value
      h.each { |k, v| h[k] = massage(v) }
      # massage each hash key
      h.rekey do |key|
        massage(key)
      end
    end

    def self.string_massage(str)
      # calls .to_s so it works for symbols too
      str.to_s.gsub('__c', '').gsub('__r', '')
    end
  end
end
