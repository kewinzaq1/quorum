module YouCom
  class ResearchClient < BaseClient
    BASE_URL = "https://api.you.com"
    PATH = "/v1/research"

    def start(input:, output_schema:)
      response = connection(BASE_URL).post(
        PATH,
        {
          input: input,
          research_effort: "standard",
          background: true,
          output_schema: output_schema
        }
      )
      parse!(response, "You.com Research")
    end

    def status(task_id)
      response = connection(BASE_URL).get("#{PATH}/#{task_id}")
      parse!(response, "You.com Research polling")
    end
  end
end
