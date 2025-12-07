# app/helpers/amazon_cover_helper.rb
module AmazonCoverHelper
  def self.url_for(isbn13)
    isbn10 = IsbnConverter.to_isbn10(isbn13)
    "https://m.media-amazon.com/images/P/#{isbn10}.01._SCLZZZZZZZ_.jpg"
  end
end
