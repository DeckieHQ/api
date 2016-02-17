class Search
  def initialize(params, sort: [], filters: [])
    params = params.to_unsafe_h

    @page    = Page.new(params[:page] || { number: 1, size: 10 })
    @sort    = Sort.new(params[:sort], accept: sort)
    @filters = Filters.new(params[:filters], accept: filters)
  end

  def valid?
    page.valid? && sort.valid? && filters.valid?
  end

  def errors
    { page: page.errors, sort: sort.errors, filters: filters.errors }
  end

  def apply(collection)
    collection.filter(filters.params).order(sort.params).paginate(page.params)
  end

  protected

  attr_reader :page, :sort, :filters
end
