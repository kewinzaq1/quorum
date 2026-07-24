require "test_helper"

class ResearchRunTest < ActiveSupport::TestCase
  test "recognizes terminal states" do
    assert research_runs(:one).terminal?
    assert_not research_runs(:two).terminal?
  end
end
