class AddTopResourceToActions < ActiveRecord::Migration[5.0]
  def up
    add_reference :actions, :top_resource, polymorphic: true, index: true
  end

  def down
    remove_reference :actions, :top_resource, polymorphic: true, index: true
  end
end
