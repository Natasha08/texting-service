class TextMessage < ApplicationRecord
  belongs_to :sender, class_name: "User"
  validates_presence_of :to_number, :text
end
