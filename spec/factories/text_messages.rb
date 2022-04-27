FactoryBot.define do
  factory :text_message do
    text { FFaker::HipsterIpsum.sentence }
    sms_message_id { FFaker::Guid.guid }
    to_number { FFaker::PhoneNumber.short_phone_number }
  end
end
