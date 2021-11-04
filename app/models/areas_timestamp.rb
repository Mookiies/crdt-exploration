class AreasTimestamp < ApplicationRecord
  belongs_to :area, optional: false

  # TODO graphql API doesn't handle this type of validation gracefull. Just says can't return null object for inspection
  # TODO save on the parent record is valid somehow
  # validate :name_is_valid_datetime
  #
  # def name_is_valid_datetime
  #   errors.add(:name, 'must be a valid datetime') if ((DateTime.parse(happened_at) rescue ArgumentError) == ArgumentError)
  # end
end
