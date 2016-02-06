class Parameters
  include ActiveModel::Validations

  attr_reader :resource_name

  validate :must_have_data

  validates :type,       presence: true, if: :has_data?
  validates :attributes, presence: true, if: :has_data?

  validate :type_matches_resource_name,  if: :has_data?

  def initialize(params, resource_name:)
    @params        = params
    @resource_name = resource_name
  end

  def has_data?
    !@params[:data].nil?
  end

  def type
    @params[:data][:type]
  end

  def attributes
    @params[:data][:attributes]
  end

  private

  def must_have_data
    errors.add(:base, :missing_data) unless has_data?
  end

  def type_matches_resource_name
    if type != resource_name
      errors.add(:type, :unmatch, { resource_name: resource_name })
    end
  end
end
