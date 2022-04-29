class TextMessage < ApplicationRecord
  belongs_to :sender, class_name: "User"
end
