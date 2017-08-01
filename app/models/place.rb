class Place < ApplicationRecord
  has_many :place, dependent: :destroy
end
