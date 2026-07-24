class SelectionsController < ApplicationController
  before_action :set_lunch_room

  def update
    candidate = @lunch_room.candidates.find(params.require(:candidate_id))

    if params[:choice] == "backup"
      if candidate == @lunch_room.locked_candidate
        redirect_to lunch_room_path(@lunch_room, anchor: "decision"), alert: "The locked lunch cannot also be the backup."
        return
      end

      @lunch_room.update!(backup_candidate: candidate)
      candidate.backup!
      notice = "#{candidate.name} is your backup."
    else
      @lunch_room.transaction do
        @lunch_room.candidates.where(status: :selected).update_all(status: Candidate.statuses[:viable])
        candidate.selected!
        @lunch_room.update!(
          locked_candidate: candidate,
          backup_candidate: (@lunch_room.backup_candidate == candidate ? nil : @lunch_room.backup_candidate),
          status: :locked
        )
      end
      notice = "Lunch locked: #{candidate.name}."
    end

    redirect_to lunch_room_path(@lunch_room, anchor: "decision"), notice: notice
  end
end
