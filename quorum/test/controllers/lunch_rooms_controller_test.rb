require "test_helper"

class LunchRoomsControllerTest < ActionDispatch::IntegrationTest
  test "shows the room form" do
    get new_lunch_room_url
    assert_response :success
    assert_select "form[action='#{lunch_rooms_path}']"
  end

  test "creates a shareable room" do
    assert_difference("LunchRoom.count") do
      post lunch_rooms_url, params: {
        lunch_room: {
          name: "Design team lunch",
          origin_text: "525 Market St",
          lunch_at: "2026-07-24T12:15",
          return_by: "2026-07-24T13:00",
          group_budget_dollars: "24"
        }
      }
    end

    room = LunchRoom.order(:created_at).last
    assert_redirected_to lunch_room_path(room)
    assert_equal 2400, room.group_budget_cents
    assert room.public_token.present?
  end

  test "shows a room by public token" do
    get lunch_room_url(lunch_rooms(:one))
    assert_response :success
    assert_select "h1", lunch_rooms(:one).name
    assert_select ".q-result-card"
  end

  test "shows an empty collecting room without adding a phantom participant" do
    room = LunchRoom.create!(
      name: "Empty room",
      origin_text: "Market St",
      lunch_at: 1.hour.from_now,
      return_by: 2.hours.from_now
    )

    get lunch_room_url(room)

    assert_response :success
    assert_equal 0, room.participants.count
    assert_select ".q-person-row", count: 0
  end
end
