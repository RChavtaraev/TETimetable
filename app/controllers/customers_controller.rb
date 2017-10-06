class CustomersController < ApplicationController
  def new
    if !is_admin?
      redirect_to controller: "sessions", action: "new"
    else
      @customer = Customer.new()
    end
  end

  def create
    if !is_admin?
      redirect_to controller: "sessions", action: "new"
    else
      @customer = Customer.new(customer_params)
      if @customer.save
        render 'edit'
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
        @customer = Customer.find(params[:id])
        @user = User.find_by(customer_id: @customer.id)
      else
        @customer = current_user.customer
        @user = current_user
      end
      @appointments = @customer.appointments.paginate(page: params[:page])
    end
  end

  def update
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    else
      @customer = Customer.find(params[:id])
      if is_admin?
        @customer = Customer.find(params[:id])
      else
        @customer = current_user.customer
      end
      begin
        @customer.transaction do
          @customer.update_attributes!(customer_params)
          #if !is_admin?
          #  @user = current_user
          #else
          #  @user = User.find_by(customer_id: @customer.id)
            #current_user.email = @customer.email
            #current_user.save!
          #end
          #if (!@user.nil?)
            #@user.update_attribute!({email: @customer.email})
          #end
          flash[:success] = "Данные сохранены"
        end
      rescue
      end
      @appointments = @customer.appointments.paginate(page: params[:page])
      render 'edit'
    end
  end

  def destroy
    @customer = Customer.find(params[:id])
    if is_admin?
      @customer.destroy
      #и еще удалить Account?
      flash[:success] = "Пациент #{@customer.name} удален"
    else
      flash[:danger] = "Ошибка доступа"
      redirect_to root_url
    end
    redirect_to customers_url
  end

  def index
    if is_admin?
      if params[:customer_name].nil?
      @customers = Customer.paginate(page: params[:page], per_page: 20)
      else
        @customers = Customer.where("name ILIKE ?", '%' + params[:customer_name] + '%').paginate(page: params[:page], per_page: 20)
      end
    else
      flash[:danger] = "Ошибка доступа"
      redirect_to root_url
    end
  end

  def show
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    else

      if is_admin?
        @customer = Customer.find(params[:id])
      else
        @customer = current_user.customer
        #flash[:danger] = "Ошибка доступа"
        #redirect_to root_url
      end
      @appointments = @customer.appointments.paginate(page: params[:page])
      render 'edit'
    end
  end

  private
  def customer_params
    params.require(:customer).permit(:name, :email, :phone, :birth_date, :address)
  end
end
