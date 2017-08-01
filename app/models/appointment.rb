class Appointment < ApplicationRecord
  belongs_to :customer
  belongs_to :place
  validates :customer_id, presence: true
  validates :place_id, presence: true

  attr_accessor :start_date
  attr_accessor :duration


  def Appointment.GetAppointmentRange(date)
    first_data = date.beginning_of_week
    last_data = date.end_of_week
    Appointment.where("start_time >= ? AND end_time <= ?", first_data, last_data)
  end

  def GetDuration()
    return ((end_time.to_i - start_time.to_i) / 60).to_i
  end

end
