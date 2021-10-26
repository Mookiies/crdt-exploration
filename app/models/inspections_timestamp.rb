class InspectionsTimestamp < ApplicationRecord
  belongs_to :inspection, optional: false
end
