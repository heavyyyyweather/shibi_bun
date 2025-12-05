# app/services/rakuten_books_client.rb
require "net/http"
require "uri"
require "json"

class RakutenBooksClient
  BASE_URL = "https://app.rakuten.co.jp/services/api/BooksBook/Search/20170404"
  APPLICATION_ID = ENV["RAKUTEN_APPLICATION_ID"]

  def self.fetch_by_isbn(isbn)
    return nil unless APPLICATION_ID.present?

    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form({
      applicationId: APPLICATION_ID,
      isbn: isbn
    })

    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    result = JSON.parse(response.body)
    result["Items"].first&.dig("Item")
  rescue StandardError => e
    Rails.logger.error "[RakutenBooksClient] Error: #{e.message}"
    nil
  end
end
