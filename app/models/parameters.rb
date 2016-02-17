class Parameters
  include ActiveModel::Validations

  attr_reader :resource_type

  validate :must_have_data

  validates :type,       presence: true, if: :has_data?
  validates :attributes, presence: true, if: :has_data?

  validate :type_matches_resource_type,  if: :has_data?

  validate :attributes_is_a_hash, if: :has_data?

  def initialize(params, resource_type:)
    @params        = params
    @resource_type = resource_type
  end

  def has_data?
    @params[:data].is_a?(Hash)
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

  def attributes_is_a_hash
    errors.add(:attributes, :invalid) unless attributes.is_a?(Hash)
  end
end
