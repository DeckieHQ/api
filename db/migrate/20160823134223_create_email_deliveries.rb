class CreateEmailDeliveries < ActiveRecord::Migration[5.0]
  def up
    create_table(:email_deliveries) do |t|
      t.belongs_to :user, index: true

      t.references :resource, polymorphic: true, index: true

      t.string :type, null: false

      t.timestamps null: false
    end
  end

  def down
    drop_table :email_deliveries
  end
end
