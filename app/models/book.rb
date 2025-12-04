class Book < ApplicationRecord
  has_many :quotes, dependent: :destroy
  has_many :book_contributions, dependent: :destroy
  has_many :contributors, through: :book_contributions

  # enum: 0=google,1=openbd,2=manual（必要に応じて増やす）
  enum api_provider: {
    google: 0,
    openbd: 1,
    manual: 2
  }, _prefix: true

  validates :title, presence: true
  validates :isbn13, length: { in: 10..13 }, uniqueness: true, allow_blank: true

  # =========================
  # ここからクラスメソッドたち
  # =========================

  # 「ISBNを渡されたら、既存Bookを探す or Google Booksから作る」
  def self.fetch_or_create_by_isbn(raw_isbn)
    # フォームから来た文字列をまず正規化（ハイフン削除）
    numeric = raw_isbn.to_s.delete("-").strip

    # すでに登録済みならそれを返す
    if (book = find_by(isbn13: numeric))
      return book
    end

    # なければ Google Books 経由で作成
    create_from_google_books(raw_isbn)
  end

  def self.parse_published_date(value)
    return nil if value.blank?

    if value.match?(/\A\d{4}\z/)
      Date.new(value.to_i, 1, 1) rescue nil
    else
      Date.parse(value) rescue nil
    end
  end

  def self.create_from_google_books(raw_isbn)
    # ① フォームから来た文字列をまず正規化（ハイフン削除）
    numeric_isbn = raw_isbn.to_s.delete("-").strip

    # 1. API から volume 情報を取得（APIにはハイフンなしで投げる）
    volume = GoogleBooksClient.fetch_by_isbn(numeric_isbn)
    return nil unless volume

    info        = volume["volumeInfo"] || {}
    identifiers = info["industryIdentifiers"] || []
    images      = info["imageLinks"] || {}
    authors     = info["authors"] || []

    # 2. ISBN の正規化（ISBN13 があれば優先）
    isbn_13 = identifiers.find { |id| id["type"] == "ISBN_13" }&.dig("identifier")
    normalized_isbn = (isbn_13.presence || numeric_isbn)

    # 3. 書影URL（なければ nil でOK）
    cover_url =
      images["extraLarge"] ||
      images["large"] ||
      images["medium"] ||
      images["thumbnail"] ||
      images["smallThumbnail"]
      
    book = create!(
      title:         info["title"],
      publisher:     info["publisher"],
      published_on:  parse_published_date(info["publishedDate"]),
      isbn13:        normalized_isbn,
      cover_url:     cover_url,
      api_provider:  :google,
      api_payload:   volume,          # JSON丸ごと入れておく
      api_synced_at: Time.current
    )

    # 4. 著者情報を Contributors / BookContributions に流し込む
    authors.each_with_index do |author_name, idx|
      contributor = Contributor.find_or_create_by!(name: author_name)

      BookContribution.find_or_create_by!(
        book: book,
        contributor: contributor,
        role: :author
      ) do |bc|
        bc.position = idx  # 1番目の著者・2番目の著者…が必要なら使える
      end
    end

    book
  end
end
