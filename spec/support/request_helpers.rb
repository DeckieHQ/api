module Request
  module JsonHelpers
    def json_response
      @json_response ||= JSON.parse(response.body, symbolize_names: true)
    end

    def json_headers
      @json_headers ||= { 'ACCEPT' => 'application/json' }
    end
  end
end
