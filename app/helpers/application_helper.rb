module ApplicationHelper
  def GetTimeRangeInSeconds(start_time, end_time)
    start_time_same_date = start_time.change(year: end_time.year, month: end_time.month, day: end_time.day)
    return end_time - start_time_same_date
  end

  def GetTime_Seconds(time)
    @retval = time.hour * 3600 + time.min * 60 + time.sec
    return @retval
  end
end
