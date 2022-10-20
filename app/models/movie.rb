class Movie < ApplicationRecord
  has_many :movie_genre, :movie_cast
  has_many :genres, through: :movie_genre
  has_many :movies, through: :movie_cast
end
