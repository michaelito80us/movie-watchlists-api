class CreateWatchlistMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :watchlist_movies do |t|
      t.references :watchlist, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.boolean :watched

      t.timestamps
    end
  end
end
