# app/models/book.rb
class Book < ApplicationRecord
  has_many :quotes, dependent: :destroy
  has_many :book_contributions, dependent: :destroy
  has_many :contributors, through: :book_contributions

  enum api_provider: {
    google: 0,
    openbd: 1,
    rakuten: 2,
    manual: 3
  }, _prefix: true

  validates :title, presence: true
  validates :isbn13, length: { in: 10..13 }, uniqueness: true, allow_blank: true

  # =========================
  # ここからクラスメソッドたち
  # =========================

  def self.fetch_or_create_by_isbn(raw_isbn)
    numeric = raw_isbn.to_s.delete("-").strip

    if (book = find_by(isbn13: numeric))
      return book
    end

    create_from_isbn_sources(numeric)
  end

  def self.parse_published_date(value)
    return nil if value.blank?

    if value.match?(/\A\d{4}\z/)
      Date.new(value.to_i, 1, 1) rescue nil
    else
      Date.parse(value) rescue nil
    end
  end

  def self.create_from_isbn_sources(isbn)
    [
      [:openbd, OpenbdClient.fetch_by_isbn(isbn)],
      [:rakuten, RakutenBooksClient.fetch_by_isbn(isbn)],
      [:google, GoogleBooksClient.fetch_by_isbn(isbn)]
    ].each do |provider, payload|
      next if payload.blank?

      book = create_book_from_payload(provider, payload, isbn)
      return book if book
    end

    nil
  end

  def self.create_book_from_payload(provider, payload, isbn)
    case provider
    when :openbd
      summary = payload["summary"]
      return nil unless summary

      title       = summary["title"] || "書名不明"
      publisher   = summary["publisher"]
      pubdate     = summary["pubdate"]
      isbn13      = summary["isbn"] || isbn
      cover_url   = summary["cover"]
      authors     = summary["author"]&.split(/[、,\/]/)&.map(&:strip) || []

      book = create!(
        title: title,
        publisher: publisher,
        published_on: parse_published_date(pubdate),
        isbn13: isbn13,
        cover_url: cover_url,
        api_provider: :openbd,
        api_payload: payload,
        api_synced_at: Time.current
      )

    when :rakuten
      item = payload["Item"]
      return nil unless item

      title       = item["title"]
      publisher   = item["publisherName"]
      pubdate     = item["salesDate"]
      isbn13      = item["isbn"] || isbn
      cover_url   = item["largeImageUrl"]
      authors     = item["author"]&.split(/[、,\/]/)&.map(&:strip) || []

      book = create!(
        title: title,
        publisher: publisher,
        published_on: parse_published_date(pubdate),
        isbn13: isbn13,
        cover_url: cover_url,
        api_provider: :rakuten,
        api_payload: payload,
        api_synced_at: Time.current
      )

    when :google
      info        = payload["volumeInfo"] || {}
      identifiers = info["industryIdentifiers"] || []
      images      = info["imageLinks"] || {}
      authors     = info["authors"] || []

      isbn13 = identifiers.find { |id| id["type"] == "ISBN_13" }&.dig("identifier") || isbn
      cover_url = images["extraLarge"] || images["large"] || images["medium"] ||
                  images["thumbnail"] || images["smallThumbnail"]

      book = create!(
        title: info["title"],
        publisher: info["publisher"],
        published_on: parse_published_date(info["publishedDate"]),
        isbn13: isbn13,
        cover_url: cover_url,
        api_provider: :google,
        api_payload: payload,
        api_synced_at: Time.current
      )

    else
      return nil
    end

    # 共通：著者の登録
    authors.each_with_index do |name, idx|
      next if name.blank?
      contributor = Contributor.find_or_create_by!(name: name)
      BookContribution.find_or_create_by!(
        book: book,
        contributor: contributor,
        role: :author
      ) { |bc| bc.position = idx }
    end

    book
  end
end
