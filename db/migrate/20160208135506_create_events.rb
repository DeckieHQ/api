class CreateEvents < ActiveRecord::Migration[5.0]
  def up
    create_table(:events) do |t|
      t.string :title,    null: false
      t.string :category, null: false
      t.string :ambiance, null: false
      t.string :level,    null: false

      t.integer :capacity, null: false

      t.boolean :auto_accept, null: false, default: false

      t.text :description

      t.datetime :begin_at, null: false
      t.datetime :end_at

      t.decimal :latitude,  precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.string :street,   null: false
      t.string :postcode, null: false
      t.string :city,     null: false
      t.string :state
      t.string :country,  null: false

      t.integer :attendees_count, null: false, default: 0

      t.timestamps null: false

      t.belongs_to :profile, index: true
    end
  end

  def down
    drop_table :events
  end
end
