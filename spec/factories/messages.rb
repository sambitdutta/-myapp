FactoryBot.define do
  factory :message do
    user { nil }
    subject { Faker::Lorem.paragraph }
    body { Faker::Lorem.paragraphs.join('\n') }
  end
end
