FactoryBot.define do
  factory :quote do
    body { "テスト用の引用文#{SecureRandom.hex(4)}" }
    page { rand(1..300) }
    status { :published }
    published_at { Time.current - rand(1..30).days }

    association :book
  end
end
