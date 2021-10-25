class Area < ApplicationRecord
  belongs_to :inspection, optional: false
  has_many :items
  accepts_nested_attributes_for :items
end
