class AppointmentsController < ApplicationController

  def new
    start_date_param = params.fetch(:start_date, Date.current)
    start_time_param = params.fetch(:start_time, (Time.current + 1.hour).at_beginning_of_hour)
    @appointment = Appointment.new(start_time: start_time_param.to_time,
                                   start_date:  start_date_param.to_date,
                                   duration: 45)
  end

  def create
    @appointment = Appointment.new(appointment_params)
  end

  private
  def appointment_params
    params.require(:appointment).permit(:customer_name, :start_time, :start_date, :duration, :comment)
  end



end
