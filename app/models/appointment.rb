class Appointment < ApplicationRecord

  def Appointment.GetAppointmentRange(date)
    first_data = date.beginning_of_week
    last_data = date.end_of_week
    Appointment.where("start_time >= ? AND end_time <= ?", first_data, last_data)
  end

end
