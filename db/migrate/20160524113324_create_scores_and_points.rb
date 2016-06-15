class CreateScoresAndPoints < ActiveRecord::Migration[5.0]
  def up
    create_table :merit_scores do |t|
      t.references :sash
      t.string :category, default: 'default'
    end

    create_table :merit_score_points do |t|
      t.references :score
      t.integer :num_points, default: 0
      t.string :log
      t.datetime :created_at
    end
  end

  def down
    drop_table :merit_scores
    drop_table :merit_score_points
  end
end
