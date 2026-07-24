require "test_helper"

class CandidateTest < ActiveSupport::TestCase
  test "requires a valid match score" do
    candidate = candidates(:one)
    candidate.match_score = 101

    assert_not candidate.valid?
  end
end
