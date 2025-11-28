# app/services/google_books_client.rb
class GoogleBooksClient
  ENDPOINT = "https://www.googleapis.com/books/v1/volumes"

  def self.fetch_by_isbn(isbn13)
    params = {
      q: "isbn:#{isbn13}",
      # key: ENV["GOOGLE_BOOKS_API_KEY"] # なくても動くが、あればより安心
    }.compact

    res = Faraday.get(ENDPOINT, params)
    
    # 念のためステータス確認（200以外ならnil扱い）
    return nil unless res.status == 200

    json = JSON.parse(res.body)

    json["items"]&.first # 1件目だけ使う
  rescue => e
    Rails.logger.error("[GoogleBooksClient] error: #{e.class} #{e.message}")
    nil
  end
end
