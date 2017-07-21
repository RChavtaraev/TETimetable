class CreateAppointments < ActiveRecord::Migration[5.0]
  def change
    create_table :appointments do |t|
      t.integer :customer_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :place_id
      t.string :comment
      t.integer :doctor_id

      t.timestamps
    end
    add_index :appointments, [:customer_id, :start_time]
    add_index :appointments, [:doctor_id, :start_time]
  end
end
