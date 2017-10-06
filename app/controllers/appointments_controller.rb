class AppointmentsController < ApplicationController

  autocomplete :customer, :name, :extra_data => [:phone, :address, :birth_date, :email, :comment]

  def new
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    else
      start_time_param = params.fetch(:start_time, (Time.current + 1.hour).at_beginning_of_hour).to_time
      end_time_param = params.fetch(:end_time, start_time_param.to_time + 1. hour).to_time
      place_id_param = params.fetch(:place_id, 0)
      @appointment = Appointment.new( start_time: start_time_param,
                                      end_time: end_time_param,
                                      place_id: place_id_param,
                                      start_date:  start_time_param.to_date,
                                      duration: Timetable.GetDuration(start_time_param, end_time_param))
      if is_admin?
        @appointment.customer = Customer.new()
      else
        @appointment.customer = current_user.customer
      end
    end
  end

  def new_dialog
    if !signed_in?
      render :js => "window.location = '/sessions/new'"
      #redirect_to controller: "sessions", action: "new"
      return
    else
      start_time_param = params.fetch(:start_time, (Time.current + 1.hour).at_beginning_of_hour).to_time
      start_time_param = (Time.current + 1.hour).at_beginning_of_hour if start_time_param.nil?
      end_time_param = params.fetch(:end_time, start_time_param.to_time + 1. hour).to_time
      place_id_param = params.fetch(:place_id, 0)
      @appointment = Appointment.new( start_time: start_time_param,
                                      end_time: end_time_param,
                                      place_id: place_id_param,
                                      start_date:  start_time_param.to_date,
                                      duration: Timetable.GetDuration(start_time_param, end_time_param))
      if is_admin?
        @appointment.customer = Customer.new()
      else
        @appointment.customer = current_user.customer
      end
    end
    respond_to do |format|
      format.html
      format.js

    end
  end

  def edit_dialog
    if !signed_in?
      render :js => "window.location = '/sessions/new'"
      return
    else
      @appointment = Appointment.find(params[:id])
      if is_admin?
        @appointment.customer = Customer.new() if @appointment.customer.nil?
      else
        @appointment.customer = current_user.customer
      end
      @appointment.start_date = @appointment.start_time.to_date
      @appointment.duration = @appointment.GetDuration() #((@appointment.end_time.to_i - @appointment.start_time.to_i) / 60).to_i
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    else
      @appointment = Appointment.new(appointment_params)
      @appointment.transaction do
        dt = SetAttributes(@appointment)
        if @appointment.save
         redirect_to controller: 'timetables', action: 'home', start_date: dt #timetable_home_url
         return
        else
          respond_to do |format|
            #format.html
            #format.js
            format.json { render json: { errors: @appointment.errors.messages}, status: :unprocessable_entity } #:unprocessable_entity
          end
        end
      end
    end
  end

  def edit
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    else
      @appointment = Appointment.find(params[:id])
      if is_admin?
        @appointment.customer = Customer.new() if @appointment.customer.nil?
      else
        @appointment.customer = current_user.customer
      end
      @appointment.start_date = @appointment.start_time.to_date
      @appointment.duration = @appointment.GetDuration() #((@appointment.end_time.to_i - @appointment.start_time.to_i) / 60).to_i
    end

  end

  def update
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    else
      @appointment = Appointment.find(params[:id])
      @appointment.transaction do
        @appointment.assign_attributes(appointment_params)
        dt = SetAttributes(@appointment)
        if @appointment.save
          flash[:success] = "Данные сохранены"
          redirect_to controller: 'timetables', action: 'home', start_date: dt.at_beginning_of_week #timetable_home_url
          return
        else
          respond_to do |format|
            #format.html
            #format.js
            format.json { render json: { errors: @appointment.errors.messages}, status: :unprocessable_entity } #:unprocessable_entity
          end
        end
        #render 'edit'
      end
    end
  end

  def SetAttributes(appointment)
    if is_admin?
      if params.require(:customer)[:id].empty?
        customer = Customer.new(customer_params)
        appointment.customer = customer
        customer.save
      else
        customer = Customer.find(params.require(:customer)[:id])
        customer.assign_attributes(customer_params)
        customer.save
      end
    else
      customer = current_user.customer #!!!user может подставить себя в чужую запись((
      customer.assign_attributes(customer_params)
      customer.save
    end


    appointment.customer = customer
    if !appointment.start_date.nil? && !appointment.start_time.nil?
      dt = appointment.start_date.to_date
      tm = appointment.start_time.utc.to_time
      appointment.start_time =  DateTime.new(dt.year, dt.month, dt.day, tm.hour, tm.min, tm.sec )
      tm = tm.to_time + appointment.duration.to_i * 60
      appointment.end_time = DateTime.new(dt.year, dt.month, dt.day, tm.hour, tm.min, tm.sec )
    end
    return dt
  end

  def destroy
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    else
      @appointment = Appointment.find(params[:id])
      if is_admin? || @appointment.customer.id == current_user.customer.id
        dt = @appointment.start_time
        @appointment.destroy
        redirect_to controller: 'timetables', action: 'home', start_date: dt
      else
        flash[:danger] = "Ошибка доступа"
      end

    end
  end

  private
  def appointment_params
    params.require(:appointment).permit(:start_time, :start_date, :duration, :comment, :place_id)
  end

  def customer_params
    params.require(:customer).permit(:id, :name, :phone, :email, :birth_date, :address)
  end

end
