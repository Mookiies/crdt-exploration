class Item < ApplicationRecord
  belongs_to :area, optional: false
end
