class Customer < ApplicationRecord
  has_many :appointments, dependent: :destroy
  validates :name, presence: { message: "ФИО пациента не может быть пустым"}
  validates :email, presence: { message: "email пациента не может быть пустым"}, if: :has_user?

  def has_user?
    !User.find_by(customer_id: id).nil?
  end
end
