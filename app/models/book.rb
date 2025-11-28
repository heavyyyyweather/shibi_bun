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
  validates :isbn13, length: { is: 13 }, allow_blank: true

  def self.create_from_google_books(isbn13)
    volume = GoogleBooksClient.fetch_by_isbn(isbn13)
    return nil unless volume

    info = volume["volumeInfo"] || {}
    identifiers = info["industryIdentifiers"] || []
    isbn_13 = identifiers.find { |id| id["type"] == "ISBN_13" }&.dig("identifier")

    create!(
      title:        info["title"],
      publisher:    info["publisher"],
      published_on: info["publishedDate"], # "2001-03-01" or "2001" 形式 → 後で整形してもよい
      isbn13:       isbn_13 || isbn13,
      api_provider:  :google,
      api_payload:  volume,
      api_synced_at: Time.current
    )
  end

  def self.parse_published_date(str)
    return nil if str.blank?

    case str
    when /\A\d{4}\z/
      Date.new(str.to_i, 1, 1)
    when /\A\d{4}-\d{2}\z/
      y, m = str.split("-").map(&:to_i)
      Date.new(y, m, 1)
    else
      Date.parse(str) rescue nil
    end
  end
end
