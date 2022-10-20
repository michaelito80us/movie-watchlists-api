class CreateMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :movies do |t|
      t.string :name
      t.string :duration
      t.string :score
      t.string :overview
      t.string :release_date
      t.string :poster_url
      t.string :tmbd_movie_id

      t.timestamps
    end
  end
end
