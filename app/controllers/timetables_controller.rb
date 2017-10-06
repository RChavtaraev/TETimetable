class TimetablesController < ApplicationController

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
    #@appointments = Appointment.where("start_time::date >= ? AND end_time::date <= ?", first_data, last_data)

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

  def update
    if is_admin?
      @timetable_item = Timetable.find(params[:id])
      @timetable_item.transaction do
        @timetable_item.assign_attributes(timetable_item_params)
        SetAttributes(@timetable_item)
        if @timetable_item.save
          flash[:success] = "Данные сохранены"
          redirect_to controller: 'timetables', action: 'editweek', start_date: @timetable_item.start_time.to_date
        else
          render 'edit'
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
      @timetables = Timetable.GetSessionsRange(params.fetch(:start_date, Date.current).to_date)
      @places=Place.all.map { |place| [place.name, place.id] }
    else
      flash[:danger] = "Ошибка доступа"
      redirect_to root_url
    end
  end

  def check_uncheck
    if is_admin?
      lastid = params[:lastid].to_i;
      for i in 0..lastid
        st = params["start_time_#{i}"]
        if !st.nil?
          et = params["end_time_#{i}"]
          checked = params["session_checked_#{i}"]
          placeid = params["place_#{i}"]
          if checked.to_i == 1
            session = Timetable.find_by(start_time: st, end_time: et)

            if session.nil?
            #if Timetable.where(start_time: st, end_time: et, place_id: placeid).empty?
              session = Timetable.new(start_time: st, end_time: et, place_id: placeid)
            end
            session.place_id = placeid
            session.duration = session.GetDuration()
            session.start_date = st.to_date
            session.save
            #Timetable.find_or_create_by!(start_time: st, end_time: et, place_id: placeid, start_date: st.to_date, duration: Timetable.GetDuration(st, et))
          else
            session = Timetable.find_by(start_time: st, end_time: et)
            if !session.nil?
              session.delete
            end
          end
        end
      end
      flash[:success] = "Данные сохранены"
      redirect_to controller: 'timetables', action: 'editweek', start_date: params["start_date"]
    else
      flash[:danger] = "Ошибка доступа"
      render 'editweek'
    end

      #st = params[:start_time]
      #et = params[:end_time]
      #checked = params[:session_checked]
      #if checked.to_i == 1
        #Timetable.find_or_create_by!(start_time: st, end_time: et)

      #else
      #  session = Timetable.find_by(start_time: st, end_time: et)
      #  if !session.nil?
      #    session.delete
      #  end

      #end

  end

  private
  def timetable_item_params
    params.require(:timetable).permit(:start_time, :start_date, :duration, :place_id)
  end

end
