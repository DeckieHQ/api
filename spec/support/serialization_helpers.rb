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

  def query(page: nil)
    query = {}

    if page
      query.merge!({ page: { number: page.number, size: page.size } })
    end
  end
end
