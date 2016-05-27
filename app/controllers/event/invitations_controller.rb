class Event::InvitationsController < ApplicationController
  before_action :authenticate!, only: [:create]

  def create
    invitation = Invitation.new(permited_attributes(Invitation))

    invitation.event = event

    authorize invitation

    unless invitation.save
      return render_validation_errors(invitation)
    end
    render json: invitation, status: 201
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end
end
