class User < ApplicationRecord
  attr_accessor :reset_token
  attr_accessor :activation_token
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

  def check_activation_token?(activation_token)
    self.activation_digest == User.encrypt(activation_token)
  end

  def check_reset_token?(reset_token)
    self.reset_digest == User.encrypt(reset_token)
  end

  def create_reset_digest
    self.reset_token = SecureRandom.urlsafe_base64
    update_attribute(:reset_digest, User.encrypt(self.reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private
    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
      self.activation_token  = User.new_remember_token
      self.activation_digest = User.encrypt(activation_token)
    end
end
