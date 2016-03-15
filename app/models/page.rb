class Page
  include ActiveModel::Validations

  attr_accessor :number, :size

  validates :number, numericality: { greater_than: 0 }
  validates :size,   numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 50 }

  def initialize(attributes = {})
    attributes = {} unless attributes.kind_of?(Hash)

    @number = attributes[:number].to_i
    @size   = attributes[:size].to_i
  end

  def params
    { page: number, per_page: size }
  end
end
