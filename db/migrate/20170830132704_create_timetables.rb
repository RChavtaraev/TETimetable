class CreateTimetables < ActiveRecord::Migration[5.0]
  def change
    create_table :timetables do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :status
      t.integer :place_id

      t.timestamps
    end
  end
end
