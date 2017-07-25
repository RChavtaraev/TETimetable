class Appointment < ApplicationRecord

  attr_reader :start_date
  def start_date=(value)
    @start_date = value
  end

  attr_reader :customer_name
  def customer_name=(value)
    @customer_name = value
  end

  attr_reader :duration
  def duration=(value)
    @duration = value
  end

  def Appointment.GetAppointmentRange(date)
    first_data = date.beginning_of_week
    last_data = date.end_of_week
    Appointment.where("start_time >= ? AND end_time <= ?", first_data, last_data)
  end

end
