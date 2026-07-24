require "test_helper"

module LunchResearch
  class OrchestratorTest < ActiveSupport::TestCase
    setup do
      @old_key = ENV["YDC_API_KEY"]
      @old_demo = ENV["DEMO_MODE"]
      ENV["YDC_API_KEY"] = "test-key"
      ENV.delete("DEMO_MODE")

      @room = lunch_rooms(:two)
      @run = @room.research_runs.create!(
        query: PromptBuilder.new(@room).query,
        started_at: Time.current
      )
    end

    teardown do
      ENV["YDC_API_KEY"] = @old_key
      ENV["DEMO_MODE"] = @old_demo
    end

    test "uses search contents and background research then persists the polled result" do
      stub_request(:post, "https://ydc-index.io/v1/search")
        .to_return(
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: { results: { web: [ { url: "https://restaurant.test/menu", title: "Menu" } ] } }.to_json
        )
      stub_request(:post, "https://ydc-index.io/v1/contents")
        .to_return(
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: [ { url: "https://restaurant.test/menu", title: "Menu", markdown: "Open for lunch. Bowls from $15." } ].to_json
        )
      stub_request(:post, "https://api.you.com/v1/research")
        .to_return(
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: { task_id: "task-live", status: "queued" }.to_json
        )

      Orchestrator.new(@run).start!

      assert @run.reload.reasoning?
      assert_equal "task-live", @run.provider_task_id
      assert_requested :post, "https://ydc-index.io/v1/search"
      assert_requested :post, "https://ydc-index.io/v1/contents"
      assert_requested :post, "https://api.you.com/v1/research"

      stub_request(:get, "https://api.you.com/v1/research/task-live")
        .to_return(
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: completed_payload.to_json
        )

      assert_difference("@room.candidates.count", 1) do
        Orchestrator.new(@run).poll!
      end

      assert @run.reload.completed?
      assert @room.reload.ready?
      assert_equal "Harbor Bowl", @room.candidates.last.name
      assert_equal 1, @room.candidates.last.sources.count
    end

    private

    def completed_payload
      {
        status: "completed",
        result: {
          output: {
            content: {
              decision_summary: "This one fits.",
              candidates: [
                {
                  name: "Harbor Bowl",
                  url: "https://restaurant.test/menu",
                  address: "1 Market St",
                  cuisine: "California",
                  price_level: "$",
                  walk_minutes: 7,
                  open_now: true,
                  summary: "Fast and inside the budget.",
                  match_score: 91,
                  status: "viable",
                  participant_assessments: [
                    {
                      participant_name: "Jon",
                      fits: true,
                      verdict: "Works for Jon",
                      reasons: [ "$15 bowls" ]
                    }
                  ],
                  sources: [
                    {
                      url: "https://restaurant.test/menu",
                      title: "Harbor Bowl menu",
                      snippet: "Open for lunch."
                    }
                  ]
                }
              ]
            },
            content_type: "object",
            sources: []
          }
        }
      }
    end
  end
end
