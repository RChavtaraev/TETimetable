class Customer < ApplicationRecord
  has_many :appointment, dependent: :destroy
end
