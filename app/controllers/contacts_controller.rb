class ContactsController < ApplicationController
  before_action :authenticate!

  def show
    render json: contact
  end

  protected

  def contact
    @contact ||= Contact.new(User.find(params[:id]))
  end
end
