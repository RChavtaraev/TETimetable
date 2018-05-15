class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def edit
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user

      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "На Ваш почтовый ящик отправлено письмо с интрукцией по смене пароля"
      redirect_to root_url
    else
      flash.now[:danger] = "Пользователь с таким email не найден"
      render 'new'
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add("Пароль не может быть пустым")
      render 'edit'
    elsif @user.update_attributes(user_params)
      sign_in @user
      flash[:success] = "Пароль был изменен."
      redirect_to root_path
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  # Confirms a valid user.
  def valid_user
    unless (@user && @user.activated? && @user.check_reset_token?(params[:id]))
      redirect_to root_url
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Время смены пароля истекло."
      redirect_to new_password_reset_url
    end
  end
end
