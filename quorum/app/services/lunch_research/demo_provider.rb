module LunchResearch
  class DemoProvider
    def initialize(research_run)
      @research_run = research_run
      @room = research_run.lunch_room
    end

    def complete!
      @research_run.update!(provider: "demo", status: :reasoning, provider_task_id: "demo-#{SecureRandom.hex(4)}")
      ResultParser.new(@research_run, payload).persist!
    end

    private

    def payload
      {
        "output" => {
          "content" => {
            "decision_summary" => "Souvla gives this group the cleanest yes: close, quick, flexible, and inside every hard limit.",
            "candidates" => [
              candidate(
                "Souvla", "https://www.souvla.com", "517 Hayes St, San Francisco",
                "Greek", "$", 8, 92, "viable",
                "Fast counter service, a strong vegetarian option, and enough buffer for the 1:00 hard stop."
              ),
              candidate(
                "Mixt", "https://www.mixt.com", "120 Sansome St, San Francisco",
                "Salads", "$$", 10, 84, "viable",
                "A flexible second choice with clear ingredients and a walk that still leaves enough time to eat."
              ),
              candidate(
                "Seoul Bowl", "https://example.com/seoul-bowl", "Market St, San Francisco",
                "Korean", "$$", 18, 58, "rejected",
                "The menu works, but the walk breaks the group’s 12-minute limit."
              ),
              candidate(
                "Boardwalk Deli", "https://example.com/boardwalk-deli", "2nd St, San Francisco",
                "Sandwiches", "$", 6, 44, "rejected",
                "Close and affordable, but today’s menu has no reliable vegetarian main."
              )
            ]
          },
          "sources" => []
        }
      }
    end

    def candidate(name, url, address, cuisine, price, walk, score, status, summary)
      {
        "name" => name,
        "url" => url,
        "address" => address,
        "cuisine" => cuisine,
        "price_level" => price,
        "walk_minutes" => walk,
        "open_now" => true,
        "summary" => summary,
        "match_score" => score,
        "status" => status,
        "participant_assessments" => @room.participants.map do |participant|
          fits = status == "viable"
          {
            "participant_name" => participant.name,
            "fits" => fits,
            "verdict" => fits ? "Works for #{participant.name}" : "Breaks a hard constraint",
            "reasons" => [ summary ]
          }
        end,
        "sources" => [
          {
            "url" => url,
            "title" => "#{name} menu and hours",
            "snippet" => "Demo source used for offline product development."
          }
        ]
      }
    end
  end
end
