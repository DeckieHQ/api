class CreateSashes < ActiveRecord::Migration[5.0]
  def up
    create_table :sashes do |t|
      t.timestamps
    end
  end

  def down
    drop_table :sashes
  end
end
