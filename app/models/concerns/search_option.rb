class SearchOption
  include ActiveModel::Validations

  validate :must_be_supported

  def initialize(attributes, accept:)
    @attributes = attributes
    @accept     = accept
  end

  private

  attr_reader :attributes, :accept

  def must_be_supported
    errors.add(:base, :unsupported, accept: accept) unless unsupported.empty?
  end

  def unsupported
    fail 'Must be implemented!'
  end
end
