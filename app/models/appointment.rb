class Appointment < ApplicationRecord
  belongs_to :customer
  validates :customer_id, presence: true
  attr_accessor :start_date
  attr_accessor :duration
  attr_accessor :customer_name




  def Appointment.GetAppointmentRange(date)
    first_data = date.beginning_of_week
    last_data = date.end_of_week
    Appointment.where("start_time >= ? AND end_time <= ?", first_data, last_data)
  end

end
