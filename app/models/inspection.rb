# frozen_string_literal: true

class Inspection < ApplicationRecord
  has_many :areas
  accepts_nested_attributes_for :areas
end
