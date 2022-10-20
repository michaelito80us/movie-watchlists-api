class ChangeColumnTypesForMovies < ActiveRecord::Migration[7.0]
  def change
    change_column :movies, :duration, 'integer USING CAST(duration AS integer)'
    change_column :movies, :score, 'integer USING CAST(score AS integer)'
    change_column :movies, :release_date, 'date USING CAST(release_date AS date)'
    change_column :movies, :tmdb_movie_id, 'integer USING CAST(tmdb_movie_id AS integer)'
  end
end
