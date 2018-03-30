class TimetablesController < ApplicationController

  include ApplicationHelper
  include TimetableHelper

  def create
    if is_admin?
      @timetable_item = Timetable.new(timetable_item_params)
      @timetable_item.transaction do
        dt = SetAttributes(@timetable_item)
        if @timetable_item.save
          redirect_to controller: 'timetables', action: 'editweek', start_date: dt #timetable_home_url
        else
          render 'new'
        end
      end
    else
      flash[:danger] = "Ошибка доступа"
      render 'new'
    end
  end

  def edit_dialog
    if is_admin?
      @timetable_item = Timetable.find(params[:id])
      @timetable_item.start_date = @timetable_item.start_time.to_date
      @timetable_item.duration = @timetable_item.GetDuration()
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    if !signed_in?
      redirect_to controller: "sessions", action: "new"
    end
    if is_admin?
      @timetable_item = Timetable.find(params[:id])
      @timetable_item.transaction do
        @timetable_item.assign_attributes(timetable_item_params)
        SetAttributes(@timetable_item)
        if @timetable_item.save
          flash[:success] = "Данные сохранены"
          redirect_to controller: 'timetables', action: 'editweek', start_date: @timetable_item.start_time.to_date
        else
          #render 'edit'
          respond_to do |format|
            #format.html
            #format.js
            format.json { render json: { errors: @timetable_item.errors.messages}, status: :unprocessable_entity } #:unprocessable_entity
          end
        end

      end
    else
      flash[:danger] = "Ошибка доступа"
      render 'edit'
    end
  end

  def SetAttributes(timetable_item)
    if !timetable_item.start_date.nil? && !timetable_item.start_time.nil?
      dt = timetable_item.start_date.to_date
      tm = timetable_item.start_time.to_time
      timetable_item.start_time =  Time.zone.local(dt.year, dt.month, dt.day, tm.hour, tm.min, tm.sec )
      tm = tm.to_time + timetable_item.duration.to_i * 60
      timetable_item.end_time = Time.zone.local(dt.year, dt.month, dt.day, tm.hour, tm.min, tm.sec )
    end
    return dt
  end

  def editweek
    if is_admin?
      @startdate = params.fetch(:start_date, Date.current).to_date.beginning_of_week
      @timetables = Timetable.GetSessionsRange(@startdate)
      @settings = TimetableHelper.getSettings(@timetables, @startdate)
      @places=Place.all.map { |place| [place.name, place.id] }
    else
      flash[:danger] = "Ошибка доступа"
      redirect_to root_url
    end
  end

  def appendranges #Create set of events by array of time ranges and interval (15, 30, 45, 60 min). Ajax using
    ranges = JSON.parse params.fetch(:selectiondata)
    interval = params.fetch(:interval).to_i #interval in minutes
    places=Place.all.map { |place| [place.name, place.id] }
    appendevents = []
    errmsg = "нет доступного времени"
    for range in ranges do
      t1 = DateTime.parse(range['firstTime']).localtime
      t2 = DateTime.parse(range['lastTime']).localtime
      free_times = []
      #get array of free times
      events = Timetable.select("start_time, end_time").where("(start_time > :firsttime AND start_time < :lasttime) OR (end_time > :firsttime AND end_time < :lasttime)", {firsttime: t1, lasttime: t2}).to_a #get events in interval
      settings = TimetableHelper.getSettings(events, Date.current)
      t_cur = t1
      for i in 0..events.length-1
        free_times << {start_time: t_cur, end_time: events[i][:start_time]} if t_cur < events[i][:start_time]
        t_cur = events[i][:end_time]
        break if t_cur >= t2
      end
      free_times << {start_time: t_cur, end_time: t2} if (t_cur < t2)
      for i in 0..free_times.length - 1 do
        fullintervalCount = (free_times[i][:end_time] - free_times[i][:start_time]) / interval.minute
        for j in 1..fullintervalCount.floor
          st = free_times[i][:start_time] + ((j - 1)*interval).minute
          et = free_times[i][:start_time] + (j*interval).minute
          #create event
          event = Timetable.new(
              start_time: st.to_time,
              end_time: et.to_time,
              start_date:  st.to_date,
              duration: Timetable.GetDuration(st.to_time, et.to_time),
              place_id: range['placeId'])

          res = event.save
          html = render_to_string partial: 'timetables/event_element', locals: {timetable: event, settings:settings, places: places}, layout: false
          appendevents << {html: html, start_time: st, end_time: et, placeid: range['placeId'], wday: st.to_date.cwday, id: event.id }
          errmsg = ""
        end
      end
    end
    respond_to do |format|
      if errmsg = ""
        format.json { render :json => {:success => true, :events => appendevents} }
        format.html
      else
        format.json { render :json => {:success => false, :errormessage => errmsg} }
        format.html
      end
    end
  end

  def deleteevents #Delete set of events . Ajax using
    eventids = (JSON.parse params.fetch(:eventids)).values
    Timetable.delete(eventids)
    respond_to do |format|
      format.json { render :json => {:success => true} }
      format.html
    end
  end

  def changeplaces #set new place ids. Ajax using
    if is_admin?
      places = JSON.parse params.fetch(:places)
      for obj in places.values do
        event = Timetable.find(obj.keys[0])
        if (!event.nil?)
          event.place_id = obj[obj.keys[0]].to_i
          event.duration = event.GetDuration()
          event.start_date = event.start_time.to_date
          b = event.save

        end
      end
      respond_to do |format|
        format.json { render :json => {:success => true} }
        format.html
      end
    end
  end

  private
  def timetable_item_params
    params.require(:timetable).permit(:start_time, :start_date, :duration, :place_id)
  end

<<DOC
def edit
    if is_admin?
      @timetable_item = Timetable.find(params[:id])
      @timetable_item.start_date = @timetable_item.start_time.to_date
      @timetable_item.duration = @timetable_item.GetDuration()
    else
      flash[:danger] = "Ошибка доступа"
      redirect_to root_url
    end
  end

def new
    if is_admin?
      start_time_param = params.fetch(:start_time, (Time.current + 1.hour).at_beginning_of_hour)
      end_time_param = params.fetch(:end_time, start_time_param.to_time + 1.hour)
      @timetable_item = Timetable.new( start_time: start_time_param.to_time,
                                       end_time: end_time_param.to_time,
                                       start_date:  start_time_param.to_date,
                                      duration: Timetable.GetDuration(start_time_param.to_time, end_time_param.to_time))
    else
      flash[:danger] = "Ошибка доступа"
      redirect_to root_url
    end
  end

def home
    date = params.fetch(:start_date, Date.current).to_date
    first_date = date.beginning_of_week.to_date
    sql_first_date = ActiveRecord::Base.sanitize(first_date)
    last_date = date.end_of_week.to_date
    sql_last_date = ActiveRecord::Base.sanitize(last_date)
    sql_current_date = ActiveRecord::Base.sanitize(Time.current.to_date)
    sql ="SELECT Apt.id, 1 AS status, start_time, end_time, place_id, customer_id, C.Name AS customer_name, C.phone AS customer_phone, places.name AS place_name
    FROM appointments AS Apt
    INNER JOIN customers as C ON C.id = customer_id
    INNER JOIN places ON places.id = place_id
    WHERE start_time::date >= #{sql_first_date} AND start_time::date <= #{sql_last_date}
    UNION
    SELECT -1 as id, 0 AS status, start_time, end_time, place_id, -1 as customer_id, '' as customer_name, '' AS customer_phone, places.name AS place_name
    FROM timetables AS T1
    INNER JOIN places ON places.id = place_id
    WHERE
          T1.start_time::date >= #{sql_first_date} AND
          T1.start_time::date <= #{sql_last_date} AND
    NOT EXISTS (
                   SELECT Id
    FROM appointments AS Apt
    WHERE Apt.start_time::date >= #{sql_first_date} AND Apt.start_time::date <= #{sql_last_date} AND
    ((T1.start_time <= Apt.start_time AND T1.end_time >= Apt.end_time) OR
    (T1.start_time <= Apt.start_time AND T1.end_time >= Apt.end_time) OR
    (T1.start_time < Apt.end_time AND T1.end_time > Apt.start_time) OR
    (T1.start_time < Apt.start_time AND T1.end_time > Apt.start_time) OR
    (T1.start_time >= Apt.start_time AND T1.end_time <= Apt.end_time))

    )
    ORDER BY start_time"

    @appointments = Appointment.find_by_sql(sql)
    @first_time = date.end_of_week.to_date + 1.day
    @appointments.each do |appointment|
      @first_time = appointment.start_time if appointment.start_time < @first_time
    end
    @settings = getSettings(@appointments, @first_time.to_date.beginning_of_week)
    #@appointments = Appointment.where("start_time::date >= ? AND end_time::date <= ?", first_data, last_data)

  end
DOC

end
