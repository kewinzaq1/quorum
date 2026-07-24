require "test_helper"

class ParticipantsControllerTest < ActionDispatch::IntegrationTest
  test "adds a person and converts dollars to cents" do
    room = lunch_rooms(:two)

    assert_difference("room.participants.count") do
      post lunch_room_participants_url(room), params: {
        participant: {
          name: "Leah",
          diet: "Gluten-free",
          max_walk_minutes: 12,
          budget_dollars: 18
        }
      }
    end

    assert_redirected_to lunch_room_path(room, anchor: "people")
    assert_equal 1800, room.participants.order(:created_at).last.budget_cents
  end
end
