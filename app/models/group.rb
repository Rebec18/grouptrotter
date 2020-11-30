class Group < ApplicationRecord
  has_many :travelers, dependent: :destroy
  validates :date_from, :date_to, presence: true
end
