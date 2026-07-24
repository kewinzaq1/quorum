module YouCom
  class SearchClient < BaseClient
    BASE_URL = "https://ydc-index.io"
    PATH = "/v1/search"

    def search(query, count: 8)
      client = connection(BASE_URL)
      response = client.post(PATH, { query: query, count: count })

      # The hackathon brief specifies POST. The current public endpoint documents
      # GET, so retain compatibility if POST is rejected at the edge.
      response = client.get(PATH, { query: query, count: count }) if [ 404, 405 ].include?(response.status)
      parse!(response, "You.com Search")
    end
  end
end
