class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.check_activation_token?(params[:id])
      user.update_attribute(:activated,    true)
      user.update_attribute(:activated_at, Time.zone.now)
      sign_in user
      flash[:success] = "Пользователь активирован"
      redirect_to root_path
    else
      flash[:danger] = "Ошибка активации пользователя"
      redirect_to root_path
    end
  end
end
