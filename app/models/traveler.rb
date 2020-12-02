class Traveler < ApplicationRecord
  belongs_to :group
  validates :name, :fly_from, presence: true
  validates :date_from, :date_to, presence: true
end
