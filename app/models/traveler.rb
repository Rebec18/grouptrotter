class Traveler < ApplicationRecord
  belongs_to :group
  validates :name, :fly_from, presence: true
end
