module LunchResearch
  class ResultParser
    def initialize(research_run, payload)
      @research_run = research_run
      @room = research_run.lunch_room
      @payload = payload.deep_stringify_keys
    end

    def persist!
      content, global_sources = extract_content_and_sources
      candidate_rows = Array(content["candidates"])
      raise YouCom::RequestError, "You.com Research returned no lunch candidates." if candidate_rows.empty?

      @room.transaction do
        @research_run.candidates.destroy_all
        candidate_rows.each { |row| persist_candidate(row, global_sources) }
        @research_run.update!(
          status: :completed,
          response_payload: @payload,
          completed_at: Time.current
        )
        @room.update!(status: :ready)
      end
    end

    private

    def extract_content_and_sources
      result = @payload["result"] || @payload
      output = result["output"] || result
      content = output["content"] || output
      content = JSON.parse(content) if content.is_a?(String)
      [ content, Array(output["sources"]) ]
    rescue JSON::ParserError
      raise YouCom::RequestError, "You.com Research returned an unreadable structured result."
    end

    def persist_candidate(row, global_sources)
      row = row.deep_stringify_keys
      candidate = @research_run.candidates.create!(
        lunch_room: @room,
        name: row["name"],
        url: row["url"],
        address: row["address"],
        cuisine: row["cuisine"],
        price_level: row["price_level"],
        walk_minutes: row["walk_minutes"],
        open_now: row["open_now"],
        summary: row["summary"],
        match_score: row["match_score"].to_i.clamp(0, 100),
        status: Candidate.statuses.key?(row["status"]) ? row["status"] : "viable",
        metadata: { "decision_summary" => extract_decision_summary }
      )
      persist_assessments(candidate, row["participant_assessments"])
      persist_sources(candidate, Array(row["sources"]).presence || global_sources)
    end

    def persist_assessments(candidate, rows)
      by_name = @room.participants.index_by { |participant| participant.name.downcase }
      Array(rows).each do |row|
        row = row.deep_stringify_keys
        participant = by_name[row["participant_name"].to_s.downcase]
        next unless participant

        candidate.candidate_assessments.create!(
          participant: participant,
          fits: row["fits"],
          verdict: row["verdict"],
          reasons: Array(row["reasons"])
        )
      end
    end

    def persist_sources(candidate, rows)
      Array(rows).first(4).each do |row|
        row = row.deep_stringify_keys
        next if row["url"].blank?

        candidate.sources.create!(
          research_run: @research_run,
          url: row["url"],
          title: row["title"].presence || URI.parse(row["url"]).host,
          snippet: row["snippet"],
          source_type: "web"
        )
      rescue URI::InvalidURIError
        next
      end
    end

    def extract_decision_summary
      result = @payload["result"] || @payload
      output = result["output"] || result
      content = output["content"] || output
      content = JSON.parse(content) if content.is_a?(String)
      content["decision_summary"]
    rescue JSON::ParserError
      nil
    end
  end
end
