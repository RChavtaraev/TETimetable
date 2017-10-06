class Place < ApplicationRecord
  has_many :appointments, dependent: :destroy
  has_many :timetables, dependent: :destroy
  validates :name, presence: { message: "Название мед. центра не может быть пустым"}
end
