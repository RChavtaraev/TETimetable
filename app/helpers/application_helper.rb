module ApplicationHelper
  def signed_in?
    false
  end

  def is_admin?
    false
  end

  def GetTimeRangeInSeconds(start_time, end_time)
    start_time_same_date = start_time.change(year: end_time.year, month: end_time.month, day: end_time.day)
    return end_time - start_time_same_date
  end
end
