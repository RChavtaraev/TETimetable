class CustomersController < ApplicationController
  def new
    @customer = Customer.new()
  end

  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      render 'edit'
    else
      render 'new'
    end
  end

  def edit
    @customer = Customer.find(params[:id])
    @appointments = @customer.appointments.paginate(page: params[:page])
  end

  def update
    @customer = Customer.find(params[:id])
    if @customer.update_attributes(customer_params)
      flash[:success] = "Данные сохранены"
    end
    @appointments = @customer.appointments.paginate(page: params[:page])
    render 'edit'
  end

  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy
    #и еще удалить Account?
    flash[:success] = "Пациент #{@customer.name} удален"
    redirect_to customers_url
  end

  def index
    if params[:customer_name].nil?
    @customers = Customer.paginate(page: params[:page], per_page: 20)
    else
      @customers = Customer.where("name ILIKE ?", '%' + params[:customer_name] + '%').paginate(page: params[:page], per_page: 20)
    end

  end

  def show
    @customer = Customer.find(params[:id])
    @appointments = @customer.appointments.paginate(page: params[:page])
    render 'edit'
  end

  private
  def customer_params
    params.require(:customer).permit(:name, :email, :phone, :birth_date, :address)
  end
end
