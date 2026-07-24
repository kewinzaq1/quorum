require "test_helper"

class LandingControllerTest < ActionDispatch::IntegrationTest
  test "shows the emotional landing page" do
    get root_url

    assert_response :success
    assert_select "h1", /Everyone’s hungry/
    assert_select "a", text: /Decide lunch together/
    assert_select "footer", /You.com/
  end
end
