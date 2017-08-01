class CreatePlaces < ActiveRecord::Migration[5.0]
  def change
    create_table :places do |t|
      t.string :name
      t.string :address
      t.string :phone
      t.string :comment
      t.string :email
      t.string :url

      t.timestamps
    end
  end
end
