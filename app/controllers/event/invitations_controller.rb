class Event::InvitationsController < ApplicationController
  before_action :authenticate!, only: [:create]

  def create
    invitation.event = event

    authorize invitation

    unless current_user.invitations << invitation
      return render_validation_errors(invitation)
    end
    render json: invitation.tap(&:send_informations), status: 201
  end

  protected

  def invitation
    @invitation ||= Invitation.new(permited_attributes(Invitation))
  end

  def event
    @event ||= Event.find(params[:event_id])
  end
end
