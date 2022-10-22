class CreateRecommendations < ActiveRecord::Migration[7.0]
  def change
    create_table :recommendations do |t|
      t.integer :recommended_movie_id, foreign_key: true
      t.integer :is_recommended_movie_id, foreign_key: true
      t.timestamps
    end
  end
end
