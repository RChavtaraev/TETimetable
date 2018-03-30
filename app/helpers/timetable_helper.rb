include ApplicationHelper
module TimetableHelper

  def self.getSettings(timetables, startdate)
    settings = {}
    settings[:earler_hour] = 9
    settings[:startdate] = startdate
    settings[:latest_hour] = 20;
    settings[:pixel_per_hour] = 27*4
    settings[:pixel_per_second] = settings[:pixel_per_hour] / 3600.00
    timetables.each do |timetable|
      settings[:earler_hour] = timetable[:start_time].hour if timetable[:start_time].hour < settings[:earler_hour]
      settings[:latest_hour] = timetable[:end_time].hour if timetable[:end_time].hour > settings[:latest_hour]
      settings[:time_in_seconds] = GetTime_Seconds(timetable[:start_time])
      #@earler_time_in_seconds = @time_in_seconds if @time_in_seconds < @earler_time_in_seconds

    end
    settings[:earler_time_in_seconds] = settings[:earler_hour] * 3600;
    return settings
  end
end
