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
