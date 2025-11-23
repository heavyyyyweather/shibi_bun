FactoryBot.define do
  factory :book do
    title { "テスト書籍#{SecureRandom.hex(3)}" }
    publisher { "テスト出版社" }
  end
end
