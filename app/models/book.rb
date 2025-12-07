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

  def self.parse_published_date(value)
    return nil if value.blank?

    if value.match?(/\A\d{4}\z/)
      Date.new(value.to_i, 1, 1) rescue nil
    elsif value.match?(/\A\d{6}\z/)
      year = value[0..3].to_i
      month = value[4..5].to_i
      Date.new(year, month, 1) rescue nil
    else
      Date.parse(value) rescue nil
    end
  end

  def self.create_from_openbd_payload(payload, fallback_isbn = nil)
    summary = payload["summary"]
    return nil unless summary

    isbn13      = summary["isbn"] || fallback_isbn
    title       = summary["title"] || "書名不明"
    publisher   = summary["publisher"]
    pubdate     = summary["pubdate"]
    cover_url   = AmazonCoverHelper.url_for(isbn13) # OpenBDのcoverを無視してAmazonに統一

    # Contributor 情報は構造的に onix から抽出
    contributors = Array.wrap(payload.dig("onix", "DescriptiveDetail", "Contributor"))
    authors = contributors
      .map { |c| c.dig("PersonName", "content") }
      .compact
      .map { |name| name.gsub(",", " ").gsub(/\d{4}(-\d{4})?$/, "").strip }
      .uniq

    book = Book.find_or_initialize_by(isbn13: isbn13)
    book.assign_attributes(
      title: title,
      publisher: publisher,
      published_on: self.parse_published_date(pubdate),
      cover_url: cover_url,
      api_provider: :openbd,
      api_payload: payload,
      api_synced_at: Time.current
    )
    book.save!

    # 著者の登録（重複回避つき）
    contributors.each_with_index do |contrib, idx|
      name = contrib.dig("PersonName", "content")
      next if name.blank?

      name = name.gsub(",", " ").gsub(/\d{4}(-\d{4})?$/, "").strip

      roles = Array.wrap(contrib["ContributorRole"])
      role_value = if roles.include?("A01")       # 著者
                 :author
               elsif roles.include?("B06")     # 翻訳者
                 :translator
               elsif roles.include?("B01")     # 編者
                 :editor
               else
                 :author                       # デフォルトは著者
               end

      contributor = Contributor.find_or_create_by!(name: name)
      BookContribution.find_or_create_by!(
        book: book,
        contributor: contributor,
        role: role_value
      ) { |bc| bc.position = idx }
    end

    book
  end
end