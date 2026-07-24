require "test_helper"

class SourceTest < ActiveSupport::TestCase
  test "requires a title and URL" do
    source = sources(:one)
    source.title = nil

    assert_not source.valid?
  end
end
