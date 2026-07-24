module YouCom
  class BaseClient
    private

    def api_key
      ENV["YDC_API_KEY"].presence || raise(
        ConfigurationError,
        "Quorum needs YDC_API_KEY to research live lunch options. Add it on Render or run with DEMO_MODE=true locally."
      )
    end

    def connection(base_url)
      Faraday.new(url: base_url) do |faraday|
        faraday.request :json
        faraday.request :retry, max: 2, interval: 0.2, backoff_factor: 2,
          exceptions: [ Faraday::TimeoutError, Faraday::ConnectionFailed ]
        faraday.response :json, content_type: /\bjson$/
        faraday.options.timeout = 45
        faraday.options.open_timeout = 8
        faraday.headers["X-API-Key"] = api_key
        faraday.headers["Accept"] = "application/json"
      end
    end

    def parse!(response, label)
      return response.body if response.success?

      detail = if response.body.is_a?(Hash)
        response.body["detail"] || response.body["message"] || response.body["error"]
      end
      raise RequestError, "#{label} failed (#{response.status})#{": #{detail}" if detail.present?}"
    end
  end
end
