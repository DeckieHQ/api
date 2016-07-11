class LocationsController < ApplicationController
  def show
    render json: Location.new(
      Rack::Request.new(request.env).location.data
    )
  end
end
