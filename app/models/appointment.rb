class Appointment < ApplicationRecord
  belongs_to :customer
  belongs_to :place
  validates :customer_id, presence: { message: "Имя пациента не может быть пустым"}
  validates :place_id, presence: true
  validates :start_date, presence: { message: "Необходимо задать дату"} #, validates_with: CheckAppointmentValidator
  validates :duration, presence: { message: "Необходимо задать длительнось" }, numericality: { only_integer: true, greater_than_or_equal_to: 15, less_than_or_equal_to: 120 } #, validates_with: CheckAppointmentValidator
  validates :start_time, presence: { message: "Необходимо задать время" } #, validates_with: CheckAppointmentValidator
  #validates_each :start_date, :start_time, :duration do |record, attr, value|

  validate do |appointment|
    existing_appointments = Appointment.where("(start_time <= :st AND end_time >= :st) OR (start_time <= :et AND end_time >= :et)",
                                              {st: appointment.start_time, et: appointment.end_time})
    if existing_appointments.length > 0
      appointment.errors[:base] << "На данное время уже существует запись"
    end
  end


  def start_date=(value)
    @age = value.to_date
  end

  def start_date
    @age
  end

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


