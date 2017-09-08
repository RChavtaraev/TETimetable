class Place < ApplicationRecord
  has_many :appointments, dependent: :destroy
  has_many :timetables, dependent: :destroy
end
