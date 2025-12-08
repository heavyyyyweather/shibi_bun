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
  
  def self.to_isbn13(isbn10)
    digits = isbn10.to_s.gsub(/[^0-9Xx]/, "")
    core10 = digits[0, 9] # チェックディジットを除いた最初の9桁

    core13_body = "978" + core10

    sum = core13_body.chars.each_with_index.sum do |c, i|
      n = c.to_i
      i.even? ? n : n * 3
    end

    check_digit = (10 - (sum % 10)) % 10
    core13_body + check_digit.to_s
  end
end