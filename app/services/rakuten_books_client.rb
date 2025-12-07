require "net/http"
require "uri"
require "json"

class RakutenBooksClient
  BASE_URL = "https://app.rakuten.co.jp/services/api/BooksBook/Search/20170404"
  APPLICATION_ID = ENV["RAKUTEN_APP_ID"] # 環境変数に設定しておく

  def self.fetch_by_isbn(isbn)
    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form({
      format: "json",
      applicationId: APPLICATION_ID,
      isbn: isbn
    })

    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    json = JSON.parse(response.body)
    json["Items"]&.first&.dig("Item")
  rescue => e
    Rails.logger.error("[RakutenBooksClient] error: #{e.class} #{e.message}")
    nil
  end
end
