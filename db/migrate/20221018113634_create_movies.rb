class CreateMovies < ActiveRecord::Migration[7.0]
  def change
    create_table :movies do |t|
      t.string :name
      t.integer :duration
      t.integer :score
      t.string :overview
      t.date :release_date
      t.string :poster_url
      t.integer :tmbd_movie_id

      t.timestamps
    end
  end
end
