class LunchRoomsController < ApplicationController
  before_action :set_lunch_room, only: :show

  def new
    start_at = Time.zone.now.change(hour: 12, min: 15)
    start_at += 1.day if start_at < Time.zone.now
    @lunch_room = LunchRoom.new(
      name: "Lunch with the team",
      lunch_at: start_at,
      return_by: start_at + 45.minutes,
      group_budget_cents: 2500
    )
  end

  def create
    @lunch_room = LunchRoom.new(lunch_room_params)
    if @lunch_room.save
      redirect_to lunch_room_path(@lunch_room), notice: "Room ready. Add the people who need a say."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @participant = Participant.new(lunch_room: @lunch_room)
    @research_run = @lunch_room.research_runs.order(created_at: :desc).first
    @candidates = @lunch_room.candidates.includes(:sources, candidate_assessments: :participant).ranked
  end

  private

  def lunch_room_params
    permitted = params.require(:lunch_room).permit(
      :name, :origin_text, :lunch_at, :return_by, :group_budget_dollars
    )
    dollars = permitted.delete(:group_budget_dollars)
    permitted[:group_budget_cents] = (BigDecimal(dollars) * 100).to_i if dollars.present?
    permitted
  end
end
