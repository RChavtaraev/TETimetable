class CreateCustomers < ActiveRecord::Migration[5.0]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :phone
      t.string :address
      t.string :comment
      t.date :birth_date
      t.string :email

      t.timestamps
    end
  end
end
