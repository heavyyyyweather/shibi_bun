require "json"

class GoogleBooksClient
  ENDPOINT = "https://www.googleapis.com/books/v1/volumes"

  def self.fetch_by_isbn(isbn13)
    params = {
      q: "isbn:#{isbn13}",
      # key: ENV["GOOGLE_BOOKS_API_KEY"] # 任意
    }.compact

    res = Faraday.get(ENDPOINT, params)
    return nil unless res.status == 200

    json = JSON.parse(res.body)
    json["items"]&.first
  rescue => e
    Rails.logger.error("[GoogleBooksClient] error: #{e.class} #{e.message}")
    nil
  end
end
