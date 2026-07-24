module LunchResearch
  class PromptBuilder
    def initialize(lunch_room)
      @lunch_room = lunch_room
    end

    def query
      [
        "restaurants near #{@lunch_room.origin_text}",
        "open for lunch #{@lunch_room.lunch_at&.strftime("%A")}",
        "menus prices walking distance"
      ].join(" ")
    end

    def input(pages: [])
      <<~PROMPT
        Find a practical lunch decision for this real group today. This is not a generic restaurant list.

        Starting point: #{@lunch_room.origin_text}
        Lunch begins: #{format_time(@lunch_room.lunch_at)}
        Everyone must return by: #{format_time(@lunch_room.return_by)}
        Shared target budget: #{money(@lunch_room.group_budget_cents)} per person

        People and non-negotiables:
        #{participant_lines}

        Live pages already discovered through You.com Search and Contents:
        #{page_evidence(pages)}

        Return 3 to 5 nearby candidates. Verify current hours, menus, price, and realistic walking time.
        Reject a place when it breaks a hard constraint and explain exactly who it breaks for.
        Rank viable places by group fit, not popularity. Never invent missing facts; lower the score and say what is uncertain.
      PROMPT
    end

    def output_schema
      {
        type: "object",
        properties: {
          decision_summary: { type: "string" },
          candidates: {
            type: "array",
            items: {
              type: "object",
              properties: {
                name: { type: "string" },
                url: { type: "string" },
                address: { type: "string" },
                cuisine: { type: "string" },
                price_level: { type: "string" },
                walk_minutes: { type: "integer" },
                open_now: { type: "boolean" },
                summary: { type: "string" },
                match_score: { type: "integer" },
                status: { type: "string", enum: %w[viable rejected] },
                participant_assessments: {
                  type: "array",
                  items: {
                    type: "object",
                    properties: {
                      participant_name: { type: "string" },
                      fits: { type: "boolean" },
                      verdict: { type: "string" },
                      reasons: { type: "array", items: { type: "string" } }
                    },
                    required: %w[participant_name fits verdict reasons],
                    additionalProperties: false
                  }
                },
                sources: {
                  type: "array",
                  items: {
                    type: "object",
                    properties: {
                      url: { type: "string" },
                      title: { type: "string" },
                      snippet: { type: "string" }
                    },
                    required: %w[url title snippet],
                    additionalProperties: false
                  }
                }
              },
              required: %w[
                name url address cuisine price_level walk_minutes open_now
                summary match_score status participant_assessments sources
              ],
              additionalProperties: false
            }
          }
        },
        required: %w[decision_summary candidates],
        additionalProperties: false
      }
    end

    private

    def participant_lines
      @lunch_room.participants.map do |participant|
        constraints = participant.constraints.presence || [ "no stated constraints" ]
        "- #{participant.name}: #{constraints.join(", ")}"
      end.join("\n")
    end

    def page_evidence(pages)
      Array(pages).first(8).map.with_index do |page, index|
        content = page["markdown"].to_s.gsub(/\s+/, " ").truncate(1_400)
        "[#{index + 1}] #{page["title"]} — #{page["url"]}\n#{content}"
      end.join("\n\n").presence || "No pages were readable. Research and cite live sources directly."
    end

    def format_time(time)
      time&.strftime("%A, %B %-d at %-I:%M %p %Z") || "not specified"
    end

    def money(cents)
      cents.present? ? "$#{cents / 100}" : "not specified"
    end
  end
end
