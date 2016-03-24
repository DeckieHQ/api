class Search
  def initialize(params, sort: [], filters: {}, include: [])
    params = params.to_unsafe_h

    @page    = Page.new(params[:page] || { number: 1, size: 10 })
    @sort    = Sort.new(params[:sort], accept: sort)
    @filters = Filters.new(params[:filters], accept: filters)
    @include = Include.new(params[:include], accept: include)
  end

  def valid?
    page.valid? && sort.valid? && filters.valid? && include.valid?
  end

  def errors
    { page: page.errors, sort: sort.errors, filters: filters.errors, include: include.errors }
  end

  def included
    include.params
  end

  def apply(collection)
    collection
    .filter(filters.params)
    .joins(sort.joins)
    .reorder(sort.params)
    .paginate(page.params)
  end

  private

  attr_reader :page, :sort, :filters, :include
end
