require "net/http"
require "uri"
require "json"

class OpenbdClient
  BASE_URL = "https://api.openbd.jp/v1/get"

  def self.fetch_by_isbn(isbn)
    uri = URI.parse("#{BASE_URL}?isbn=#{isbn}")
    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    result = JSON.parse(response.body)
    result.first # 配列で返ってくるため
  rescue StandardError => e
    Rails.logger.error "[OpenBDClient] Error: #{e.message}"
    nil
  end
end
