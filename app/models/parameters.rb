class Parameters
  include ActiveModel::Validations

  attr_reader :resource_type

  validate :must_have_data

  validates :type,       presence: true, if: :has_data?
  validates :attributes, presence: true, if: :has_data?

  validate :type_matches_resource_type,  if: :has_data?

  def initialize(params, resource_type:)
    @params        = params
    @resource_type = resource_type
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

  def type_matches_resource_type
    if type != resource_type
      errors.add(:type, :unmatch, { resource_type: resource_type })
    end
  end
end
