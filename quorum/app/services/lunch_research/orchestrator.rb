module LunchResearch
  class Orchestrator
    def initialize(research_run)
      @research_run = research_run
      @room = research_run.lunch_room
      @prompt = PromptBuilder.new(@room)
    end

    def start!
      if ActiveModel::Type::Boolean.new.cast(ENV["DEMO_MODE"])
        DemoProvider.new(@research_run).complete!
        return
      end

      @room.update!(status: :researching)
      @research_run.searching!
      search_payload = YouCom::SearchClient.new.search(@prompt.query)
      results = Array(search_payload.dig("results", "web")).first(8)

      @research_run.reading!
      pages = YouCom::ContentsClient.new.fetch(results.filter_map { |row| row["url"] })

      @research_run.reasoning!
      input = @prompt.input(pages: pages)
      task = YouCom::ResearchClient.new.start(input: input, output_schema: @prompt.output_schema)
      @research_run.update!(
        provider_task_id: task.fetch("task_id"),
        request_payload: {
          "query" => @prompt.query,
          "search" => search_payload,
          "contents" => pages,
          "research_input" => input
        }
      )
    end

    def poll!
      return if @research_run.terminal?
      return DemoProvider.new(@research_run).complete! if @research_run.demo?
      return if @research_run.provider_task_id.blank?

      payload = YouCom::ResearchClient.new.status(@research_run.provider_task_id)
      case payload["status"]
      when "completed"
        ResultParser.new(@research_run, payload).persist!
      when "failed", "cancelled"
        message = payload.dig("error", "message") || payload["error"] || "You.com Research could not finish this run."
        @research_run.update!(status: :failed, response_payload: payload, error_message: message)
        @room.update!(status: :collecting)
      else
        @research_run.update!(status: :reasoning, response_payload: payload)
      end
    end
  end
end
