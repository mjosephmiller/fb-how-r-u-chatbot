class CreateMoodReviews < ActiveRecord::Migration
  def change
    create_table :mood_reviews do |t|
      t.text :thoughts
      t.integer :rating
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
