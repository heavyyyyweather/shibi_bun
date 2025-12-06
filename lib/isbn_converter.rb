# app/lib/isbn_converter.rb
module IsbnConverter
  def self.to_isbn10(isbn13)
    core = isbn13[3..-2] # ISBN13の真ん中9桁
    sum = core.chars.each_with_index.sum { |c, i| (10 - i) * c.to_i }
    check_digit = 11 - (sum % 11)
    check = case check_digit
            when 10 then "X"
            when 11 then "0"
            else check_digit.to_s
            end
    core + check
  end
end
