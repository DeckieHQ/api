class Serialized
  def initialize(serializer)
    @serializer = serializer
  end

  def attributes
    content['data']['attributes']
  end

  private

  def content
    @content ||= JSON.parse(
      ActiveModel::Serializer::Adapter.create(@serializer).to_json
    )
  end
end

module Serialize
  extend self

  def params(attributes = {}, type:)
    {
      data: {
        type: type,
        attributes: attributes
      }
    }
  end
end
