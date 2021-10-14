class Area < ApplicationRecord
  belongs_to :inspection
  has_many :items
end
