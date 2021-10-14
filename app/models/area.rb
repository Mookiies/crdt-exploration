class Area < ApplicationRecord
  belongs_to :inspection, optional: false
  has_many :items
end
