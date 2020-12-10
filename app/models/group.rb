class Group < ApplicationRecord
  has_many :travelers, dependent: :destroy
  validates :fly_to, presence: true
end
