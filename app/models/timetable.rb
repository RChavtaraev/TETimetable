class Timetable < ApplicationRecord
  belongs_to :place
  validates :place_id, presence: true
  validates :start_date, presence: { message: "Необходимо задать дату"}
  validates :duration, presence: { message: "Необходимо задать длительнось" }, numericality: { only_integer: true, greater_than_or_equal_to: 15, less_than_or_equal_to: 120 }
  validates :start_time, presence: { message: "Необходимо задать время" }

  validate do |timetable|
    #existing_appointments = Appointment.where("(id <> :id) AND ((start_time < :st AND end_time >= :st) OR (start_time < :et AND end_time >= :et))",
    #                                          {st: appointment.start_time, et: appointment.end_time, id: appointment.id })
    existing_timetables = Timetable.where(  "(id <> :id) AND ((:st <= start_time AND :et >= end_time) OR
        (:st <= start_time AND :et >= end_time) OR
        (:st < end_time AND :et > start_time) OR
        (:st < start_time AND :et > start_time) OR
        (:st >= start_time AND :et <= end_time))",
                                                {st: timetable.start_time, et: timetable.end_time, id: timetable.id })

    if existing_timetables.length > 0
      timetable.errors[:base] << "На данное время уже существует элемент расписания"
    end
  end



  def Timetable.GetSessionsRange(date)
    first_date = date.beginning_of_week
    last_date = date.end_of_week
    db_table = Timetable.where("start_time::date >= ? AND end_time::date <= ?", first_date, last_date)

    start_time = '09:00:00 +3'.to_time
    day_times = []
    session_count = 10 #число приемов в день
    session_length = 60 #продолжительность приема
    for i in 0..session_count-1
      day_times << start_time + i.hours
    end
    full_table = db_table.to_a
    for i in 0..6 # week days
      day_date = first_date + i.day
      day_times.each do |session_time|
        start_dt = Time.zone.local(day_date.year, day_date.month, day_date.day, session_time.hour, session_time.min, session_time.sec)
        end_dt = start_dt + session_length.minutes
        #if local_table.where("(:st <= start_time AND :et >= end_time) OR (:st < end_time AND :et > start_time) OR (:st < start_time AND :et > start_time) OR (:st >= start_time AND :et <= end_time)", {st: start_dt, et: end_dt }).empty?
        #if !Timetable.FindByDates(db_table,start_dt,end_dt)
        #  full_table << db_table.new(start_time: start_dt, end_time: end_dt, status: -1)
        #end
      end
    end
    return full_table
  end

  def start_date=(value)
    @age = value.to_date
  end

  def start_date
    @age
  end

  attr_accessor :duration

  def GetDuration()
    #return ((end_time.to_i - start_time.to_i) / 60).to_i
    return Timetable.GetDuration(start_time, end_time)
  end

  def Timetable.GetDuration(start_time, end_time)
    return ((end_time.to_i - start_time.to_i) / 60).to_i
  end

  #private
    def Timetable.FindByDates(table,st,et)
      table.each do |row|
        if (st <= row[:start_time] && et >= row[:end_time]) ||
            (st < row[:end_time] && et > row[:start_time]) ||
            (st < row[:start_time] && et > row[:start_time]) ||
            (st >= row[:start_time] && et <= row[:end_time])
          return true
        end
      end
      return false
    end

end
