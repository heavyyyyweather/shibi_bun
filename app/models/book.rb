# app/models/book.rb

class Book < ApplicationRecord
  has_many :quotes, dependent: :destroy
  has_many :book_contributions, dependent: :destroy
  has_many :contributors, through: :book_contributions

  attr_accessor :author_name

  enum api_provider: {
    google: 0,
    openbd: 1,
    rakuten: 2,
    manual: 3
  }, _prefix: true

  before_validation :normalize_isbn13

  validates :title, presence: true
  validates :isbn13, length: { in: 10..13 }, uniqueness: true, allow_blank: true
  
  # 手動登録レコードのときだけ、ISBN/著者/出版社も必須
  with_options if: :api_provider_manual? do
    validates :isbn13, presence: true
    validates :author_name, presence: true
    validates :publisher, presence: true
  end

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

  def self.clean_person_name(name)
    return "" if name.blank?

    name
      .gsub(/[,\uFF0C]/, " ")       # 半角・全角カンマをスペースに
      .gsub(/\d{4}(?:-\d{0,4})?/, "") # 1949- / 1821-1881 みたいな年情報をざっくり削除
      .gsub(/\s+/, " ")             # 連続スペースを1つに
      .strip
  end

  def self.create_from_openbd_payload(payload, fallback_isbn = nil)
    summary = payload["summary"]
    return nil unless summary

    isbn13      = summary["isbn"] || fallback_isbn
    title       = summary["title"] || "書名不明"
    publisher   = summary["publisher"]
    pubdate     = summary["pubdate"]
    cover_url   = AmazonCoverHelper.url_for(isbn13)

    contributors = Array.wrap(payload.dig("onix", "DescriptiveDetail", "Contributor"))

    authors = contributors
      .map { |c| clean_person_name(c.dig("PersonName", "content")) }
      .reject(&:blank?)
      .uniq

    book = Book.find_or_initialize_by(isbn13: isbn13)
    book.assign_attributes(
      title:        title,
      publisher:    publisher,
      published_on: parse_published_date(pubdate),
      cover_url:    cover_url,
      api_provider: :openbd,
      api_payload:  payload,
      api_synced_at: Time.current
    )
    book.save!

    # 著者の登録（重複回避つき）
    contributors.each_with_index do |contrib, idx|
      raw_name = contrib.dig("PersonName", "content")
      name     = clean_person_name(raw_name)
      next if name.blank?

      roles = Array.wrap(contrib["ContributorRole"])
      role_value =
        if roles.include?("A01")
          :author
        elsif roles.include?("B06")
          :translator
        elsif roles.include?("B01")
          :editor
        else
          :author
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

  private

  def normalize_isbn13
    return if isbn13.blank?

     # 数字と X/x だけ残す（10桁・13桁どっちでもOK）
    self.isbn13 = isbn13.to_s.gsub(/[^0-9Xx]/, "")
  end
end