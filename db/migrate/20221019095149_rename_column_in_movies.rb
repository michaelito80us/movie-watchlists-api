class RenameColumnInMovies < ActiveRecord::Migration[7.0]
  def change
    rename_column :movies, :tmbd_movie_id, :tmdb_movie_id
  end
end
