class BookLookupService
  CLIENTS = [OpenbdClient, RakutenBooksClient, GoogleBooksClient]

  def self.lookup(isbn)
    CLIENTS.each do |client|
      result = client.fetch_by_isbn(isbn)
      next unless result

      data = normalize_result(result, client.name)
      return data if data
    end

    nil
  end

  private

  def self.normalize_result(result, provider)
    case provider
    when "OpenbdClient"
      summary = result["summary"] || {}
      return nil if summary.blank?

      {
        title: summary["title"],
        publisher: summary["publisher"],
        published_on: summary["pubdate"],
        isbn13: summary["isbn"],
        cover_url: amazon_cover_url(summary["isbn"]),
        provider: "openbd"
      }
    when "RakutenBooksClient"
      {
        title: result["title"],
        publisher: result["publisherName"],
        published_on: result["salesDate"],
        isbn13: result["isbn"],
        cover_url: amazon_cover_url(result["isbn"]),
        provider: "rakuten"
      }
    when "GoogleBooksClient"
      info = result["volumeInfo"]
      isbn = info["industryIdentifiers"]&.find { |id| id["type"] == "ISBN_13" }&.dig("identifier")
      return nil unless isbn

      {
        title: info["title"],
        publisher: info["publisher"],
        published_on: info["publishedDate"],
        isbn13: isbn,
        cover_url: amazon_cover_url(isbn),
        provider: "google"
      }
    else
      nil
    end
  end

  def self.amazon_cover_url(isbn13)
    "https://images-na.ssl-images-amazon.com/images/P/#{isbn13}.09.MZZZZZZZ.jpg"
  end
end
