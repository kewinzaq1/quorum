require "test_helper"

class LunchRoomTest < ActiveSupport::TestCase
  test "assigns a public token" do
    room = LunchRoom.create!(
      name: "Lunch",
      origin_text: "Market St",
      lunch_at: 1.hour.from_now,
      return_by: 2.hours.from_now
    )

    assert room.public_token.present?
    assert_equal room.public_token, room.to_param
  end

  test "return time must follow lunch time" do
    room = LunchRoom.new(name: "Lunch", origin_text: "Market St", lunch_at: 2.hours.from_now, return_by: 1.hour.from_now)

    assert_not room.valid?
    assert_includes room.errors[:return_by], "must be after lunch starts"
  end
end
