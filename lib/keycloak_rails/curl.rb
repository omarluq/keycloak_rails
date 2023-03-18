# frozen_string_literal: true

module KeycloakRails
  # https client with farady v > 2.0.0
  class Curl
    def initialize
      @faraday = Faraday.new(url: KeycloakRails.auth_server_url)
    end

    def post(path: '', headers: { 'Content-Type': 'application/json' }, body: {})
      request = @faraday.post(path) do |req|
        req.headers = headers
        req.body = body
      end
      extract_response(request)
    end

    def get(path: '', headers: { 'Content-Type': 'application/json' }, body: {})
      request = @faraday.get(path) do |req|
        req.headers = headers
        req.body = body
      end
      extract_response(request)
    end

    def patch(path: '', headers: { 'Content-Type': 'application/json' }, body: {})
      request = @faraday.patch(path) do |req|
        req.headers = headers
        req.body = body
      end
      extract_response(request)
    end

    def put(path: '', headers: { 'Content-Type': 'application/json' }, body: {})
      request = @faraday.put(path) do |req|
        req.headers = headers
        req.body = body
      end
      extract_response(request)
    end

    private

    def extract_response(request)
      case request.status
      when 200..299 then response_to request, message: 'succeeded', status: :ok
      when 300..399 then response_to request, message: 'succeeded', status: :ok
      when 400..499 then response_to request, message: 'something went wrong', status: :unprocessed
      when 500..599 then response_to request, message: 'something went wrong', status: :unprocessed
      else response_to request, message: 'something went wrong', status: :unprocessed
      end
    end

    def response_to(request, message: '', status: :ok)
      { response: request.body && request.body != '' ? JSON.parse(request.body) : {}, message: message, status: status }
    end
  end
end
