module Etsy

  class OAuthTokenRevoked < StandardError; end
  class MissingShopID < StandardError; end
  class EtsyJSONInvalid < StandardError; end
  class TemporaryIssue < StandardError; end
  class InvalidUserID < StandardError; end

  # = Response
  #
  # Basic wrapper around the Etsy JSON response data
  #
  class Response

    # Create a new response based on the raw HTTP response
    def initialize(raw_response)
      @raw_response = raw_response
    end

    # Convert the raw JSON data to a hash
    def to_hash
      check_data!
      @hash ||= json
    end

    def body
      @raw_response.body
    end

    def code
      @raw_response.code
    end

    # Number of records in the response results
    def count
      to_hash['pagination'] ? to_hash['results'].size : to_hash['count']
    end

    # Results of the API request
    def result
      if success?
        results = to_hash['results'] || []
        count == 1 ? results.first : results
      else
        []
      end
    end

    def success?
      !!(code =~ /2\d\d/)
    end

    private

    def data
      @raw_response.body
    end

    def json
      @hash ||= JSON.parse(data)
    end

    def check_data!
      raise OAuthTokenRevoked         if data == "oauth_problem=token_revoked"
      raise MissingShopID             if data =~ /Shop with PK shop_id/
      raise InvalidUserID             if data =~ /is not a valid user_id/
      raise TemporaryIssue            if data =~ /Temporary Etsy issue|Resource temporarily unavailable|You have exceeded/
      raise EtsyJSONInvalid.new(data) unless valid_json?
      true
    end

    def valid_json?
      json
      return true
    rescue JSON::ParserError
      return false
    end

  end
end
