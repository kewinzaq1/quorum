module YouCom
  class ContentsClient < BaseClient
    BASE_URL = "https://ydc-index.io"
    PATH = "/v1/contents"

    def fetch(urls)
      return [] if urls.blank?

      response = connection(BASE_URL).post(
        PATH,
        {
          urls: urls.first(10),
          formats: %w[markdown metadata],
          crawl_timeout: 12,
          max_age: 3_600
        }
      )
      parse!(response, "You.com Contents")
    end
  end
end
