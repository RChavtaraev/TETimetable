class Customer < ApplicationRecord
  has_many :appointments, dependent: :destroy
  validates :name, presence: { message: "ФИО пациента не может быть пустым"}
  #validates :email, presence: true
end
