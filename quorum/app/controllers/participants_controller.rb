class ParticipantsController < ApplicationController
  before_action :set_lunch_room

  def create
    @participant = @lunch_room.participants.new(participant_params)
    if @participant.save
      redirect_to lunch_room_path(@lunch_room, anchor: "people"), notice: "#{@participant.name} has a say."
    else
      redirect_to lunch_room_path(@lunch_room, anchor: "people"), alert: @participant.errors.full_messages.to_sentence
    end
  end

  private

  def participant_params
    permitted = params.require(:participant).permit(
      :name, :diet, :dislikes, :max_walk_minutes, :budget_dollars, :hard_stop
    )
    dollars = permitted.delete(:budget_dollars)
    permitted[:budget_cents] = (BigDecimal(dollars) * 100).to_i if dollars.present?
    permitted
  end
end
