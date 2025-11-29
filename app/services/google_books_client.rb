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

  # 追加: フリーワード検索（タイトル、著者、ISBN など）
  def self.search(query, max_results: 10)
    return [] if query.blank?

    res = Faraday.get(ENDPOINT, {
      q: query,
      maxResults: max_results,
      langRestrict: "ja"  # 必要なら
    })

    body = JSON.parse(res.body) rescue {}
    (body["items"] || [])
  end
end
