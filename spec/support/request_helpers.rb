module Request
  module JsonHelpers
    def json_response
      @json_response ||= JSON.parse(response.body, symbolize_names: true)
    end

    def json_headers
      headers = {}

      if defined?(authenticate)
        headers = {
          'Authorization': "Token token=#{authenticate.authentication_token}"
        }
      end
      headers.merge({
        'Accept':       'application/vnd.api+json',
        'Content-Type': 'application/vnd.api+json'
      })
    end
  end
end
