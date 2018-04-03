class PlacesController < ApplicationController
  def new
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    else
      if !is_admin?
        flash[:danger] = "Ошибка доступа"
        redirect_to root_url
      else
        @place = Place.new()
      end
    end
  end

  def create
    if !is_admin?
      redirect_to controller: "sessions", action: "new"
    else
      @place = Place.new(place_params)
      if @place.save
        redirect_to places_url
      else
        render 'new'
      end
    end
  end

  def update
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    else
      @place = Place.find(params[:id])
      if is_admin?
        if @place.update_attributes(place_params)
          flash[:success] = "Данные сохранены"
        end
      else
        flash[:danger] = "Ошибка доступа"
      end
    end
    render "edit"
  end

  def edit
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    else
      if is_admin?
        @place = Place.find(params[:id])
      else
        flash[:danger] = "Ошибка доступа"
        redirect_to root_url
      end
    end
  end

  def destroy
    @place = Place.find(params[:id])
    if is_admin?
      @place.destroy
      flash[:success] = "Мед. центр #{@place.name} удален"
    else
      flash[:danger] = "Ошибка доступа"
      redirect_to root_url
      return
    end
    redirect_to places_url
  end

  def index
    if is_admin?
        @places = Place.paginate(page: params[:page], per_page: 20)
    else
      flash[:danger] = "Ошибка доступа"
      redirect_to root_url
    end
  end

  def show
  end

  def place_params
    params.require(:place).permit(:name, :email, :phone, :url, :address, :comment)
  end
end
