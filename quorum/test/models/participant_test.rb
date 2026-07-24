require "test_helper"

class ParticipantTest < ActiveSupport::TestCase
  test "summarizes human-readable constraints" do
    participant = participants(:one)

    assert_includes participant.constraints, "Vegetarian"
    assert_includes participant.constraints, "12 min walk"
    assert_includes participant.constraints, "$25 max"
  end
end
