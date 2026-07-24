require "test_helper"

class SelectionsControllerTest < ActionDispatch::IntegrationTest
  test "locks a viable candidate" do
    room = lunch_rooms(:one)
    candidate = candidates(:one)

    patch lunch_room_selection_url(room), params: { candidate_id: candidate.id, choice: "lock" }

    assert_redirected_to lunch_room_path(room, anchor: "decision")
    assert_equal candidate, room.reload.locked_candidate
    assert room.locked?
    assert candidate.reload.selected?
  end

  test "keeps a backup" do
    room = lunch_rooms(:one)
    candidate = candidates(:one)

    patch lunch_room_selection_url(room), params: { candidate_id: candidate.id, choice: "backup" }

    assert_equal candidate, room.reload.backup_candidate
    assert candidate.reload.backup?
  end

  test "does not let the locked choice become its own backup" do
    room = lunch_rooms(:one)
    candidate = candidates(:one)
    room.update!(locked_candidate: candidate, status: :locked)

    patch lunch_room_selection_url(room), params: { candidate_id: candidate.id, choice: "backup" }

    assert_nil room.reload.backup_candidate
    assert_equal "The locked lunch cannot also be the backup.", flash[:alert]
  end
end
