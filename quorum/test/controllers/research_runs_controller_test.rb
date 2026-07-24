require "test_helper"

class ResearchRunsControllerTest < ActionDispatch::IntegrationTest
  test "starts a research run in explicit demo mode without calling the network" do
    room = lunch_rooms(:two)
    old_demo = ENV["DEMO_MODE"]
    ENV["DEMO_MODE"] = "true"

    assert_difference("room.research_runs.count") do
      post lunch_room_research_runs_url(room)
    end

    run = room.research_runs.order(:created_at).last
    assert_redirected_to lunch_room_research_run_path(room, run)
    assert run.demo?
  ensure
    ENV["DEMO_MODE"] = old_demo
  end

  test "returns completed polling state as json" do
    room = lunch_rooms(:one)
    run = research_runs(:one)

    get lunch_room_research_run_url(room, run, format: :json)

    assert_response :success
    assert_equal "completed", response.parsed_body["status"]
    assert_equal lunch_room_path(room), response.parsed_body["room_url"]
  end
end
