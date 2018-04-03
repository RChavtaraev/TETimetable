class UsersController < ApplicationController
  def new
    @user = User.new()
    @user.customer = Customer.new()
  end

  def create
    #user_params = params.require(:user).permit(:name, :email, :password, :password_confirmation)
    customer_params = params.require(:customer).permit(:name, :phone, :birth_date, :address)
    @user = User.new(user_params)
    @user.isadmin = 0
    @user.transaction do
      customer_params = params.require(:customer).permit(:name, :email, :phone, :birth_date, :address)
      customer = Customer.new(customer_params)
      customer.email = @user.email
      @user.customer = customer
      if customer.save
        if @user.save
          sign_in @user
          flash[:success] = "Добро пожаловать!"
          redirect_to controller: 'timetables', action: 'home'
        else
          render 'new'
        end
      else
        render 'new'
      end
    end
  end

  def edit
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    else
      if is_admin?
        @user = User.find(params[:id])
      else
        @user = current_user
      end
    end
  end

  def update
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    else
      @user = User.find(params[:id])
      if (is_admin? || current_user.id == @user.id)
        if @user.update_attributes(user_params)
          flash[:success] = "Данные сохранены"
        end
      else
        flash[:danger] = "Ошибка доступа"
      end
    end
    render "edit"
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
