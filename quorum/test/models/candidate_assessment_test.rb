require "test_helper"

class CandidateAssessmentTest < ActiveSupport::TestCase
  test "allows one assessment per person and candidate" do
    duplicate = CandidateAssessment.new(
      candidate: candidates(:one),
      participant: participants(:one),
      fits: true
    )

    assert_not duplicate.valid?
  end
end
