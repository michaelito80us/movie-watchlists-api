class CreateRecommendations < ActiveRecord::Migration[7.0]
  def change
    create_table :recommendations do |t|
      t.references :movie,             null: false, foreign_key: true
      t.references :recommended_movie, null: false, foreign_key: { to_table: :movies }
    end
  end
end
