# app/services/book_lookup_service.rb

# 上部に helper を明示的に読み込む
require Rails.root.join("lib/amazon_cover_helper")

class BookLookupService
  CLIENTS = [OpenbdClient]

  def self.lookup(isbn)
    CLIENTS.each do |client|
      Rails.logger.debug("[BookLookupService] Trying #{client.name}")
      result = client.fetch_by_isbn(isbn)
      next unless result

      data = normalize_result(result, client.name)
      if data
        Rails.logger.debug("[BookLookupService] Used provider: #{data[:api_provider]}")
        return data
      end
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
        author: summary["author"], # => contributors へも使える
        publisher: summary["publisher"],
        published_on: summary["pubdate"],
        isbn13: summary["isbn"],
        cover_url: AmazonCoverHelper.url_for(summary["isbn"]),
        api_provider: "openbd",
        api_synced_at: Time.current,
        api_payload: result.to_json,
        contributors: summary["author"] # 文字列で保持するならこれでOK
      }

    when "RakutenBooksClient"
      {
        title: result["title"],
        author: result["author"],
        publisher: result["publisherName"],
        published_on: result["salesDate"],
        isbn13: result["isbn"],
        cover_url: AmazonCoverHelper.url_for(result["isbn"]),
        api_provider: "rakuten"
      }

    when "GoogleBooksClient"
      info = result["volumeInfo"]
      isbn = info["industryIdentifiers"]&.find { |id| id["type"] == "ISBN_13" }&.dig("identifier")
      return nil unless isbn

      {
        title: info["title"],
        author: Array(info["authors"]).join(", "),
        publisher: info["publisher"],
        published_on: info["publishedDate"],
        isbn13: isbn,
        cover_url: AmazonCoverHelper.url_for(isbn),
        api_provider: "google"
      }

    else
      nil
    end
  end
end
