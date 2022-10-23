class CreateMoviesGenres < ActiveRecord::Migration[7.0]
  def change
    create_table :movies_genres, id: false do |t|
      t.belongs_to :movie
      t.belongs_to :genre
    end

    create_table :genres_movies, id: false do |t|
      t.belongs_to :movie
      t.belongs_to :genre
    end
  end
end
