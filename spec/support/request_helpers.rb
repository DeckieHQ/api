module Request
  module JsonHelpers
    def json_response
      @json_response ||= JSON.parse(response.body, symbolize_names: true)
    end

    def json_headers
      headers = {}
      if defined?(authentified) && authentified
        headers = {
          'Authorization' => "Token token=#{user.authentication_token}"
        }
      end
      headers.merge({ 'ACCEPT' => 'application/json' })
    end
  end
end
