class User < ApplicationRecord
  belongs_to :customer, optional: true
  before_save { self.email = email.downcase }
  #before_save { self.name = name.upcase }
  before_create :create_remember_token
  validates :name, presence: { message: "Имя не может быть пустым"}, uniqueness: { message: "Пользователь с таким именем уже существует"} #true
  validates :email, presence: { message: "Email не может быть пустым"}, email_format: { message: "Неверный формат email" }, uniqueness: true
  validates :isadmin, presence: true
  has_secure_password
  validates :password, length: { minimum: 6 }

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  private
    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
