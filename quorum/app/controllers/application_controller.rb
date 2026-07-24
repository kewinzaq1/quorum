class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def set_lunch_room
    token = params[:lunch_room_token] || params[:token]
    @lunch_room = LunchRoom.find_by!(public_token: token)
  end
end
