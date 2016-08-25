module RequestHelpers
  module Json
    def json_response
      @json_response ||= JSON.parse(response.body, symbolize_names: true)
    end

    def json_data
      @json_data ||= json_response[:data]
    end

    def json_attributes
      @json_attributes ||= json_data[:attributes]
    end

    def json_attributes_for(record)
      @json_attributes_for ||= json_data[ json_data.index { |data| data[:id] == record.id.to_s } ][:attributes]
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
