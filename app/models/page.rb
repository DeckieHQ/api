class Page
  include ActiveModel::Validations

  attr_accessor :number, :size

  validates :number, numericality: { greater_than: 0 }
  validates :size,   numericality: { greater_than: 0, less_than_or_equal_to: 50 }

  def initialize(params = {})
    @number = params[:number].to_i
    @size   = params[:size].to_i
  end

  def params
    { page: number, per_page: size }
  end
end
